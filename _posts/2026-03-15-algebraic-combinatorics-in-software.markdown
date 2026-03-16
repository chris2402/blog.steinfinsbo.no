---
layout: post
title: "Algebraic combinatorics and the languages that reason about structure"
date: 2026-03-15 18:00:00 +0100
categories: mathematics programming
published: false
---

You've used algebraic combinatorics without knowing it.

Every time you write a recursive query to flatten a dependency graph, generate test cases by enumerating valid orderings, or compose access-control rules with AND and OR, you are operating on structures that algebraic combinatorics has studied for over a century. The theory has names for these structures, properties that follow from those names, and algorithms you can reach for once you recognise what you're looking at.

This post covers four structures: **permutations** (and the symmetric group), **posets**, **lattices**, and **Boolean algebras**. For each one, we'll look at how it appears in real tools — Prolog, SQL, GraphQL, and a design pattern that spans Rust and C#. The GraphQL connection is structural rather than computational, and I'll say so plainly; the others are the real thing.

By the end you'll have vocabulary that unlocks decades of theory, plus a few immediate practical payoffs.

---

## Four structures worth knowing

**Permutations and the symmetric group S_n.** A permutation of a set is a bijection from the set to itself — a rearrangement. The set of all permutations of n elements under composition forms the symmetric group S_n, which has n! elements. That factorial is the reason brute-force enumeration dies quickly: S_10 has 3.6 million elements, S_20 has 2.4 × 10^18. Knowing you're working with a permutation space tells you immediately that you need pruning, symmetry reduction, or a smarter algorithm. *We'll see this in Prolog.*

**Posets.** A partially ordered set is a set P with a relation ≤ that is reflexive (a ≤ a), antisymmetric (a ≤ b and b ≤ a implies a = b), and transitive (a ≤ b and b ≤ c implies a ≤ c). The word "partial" means not every pair needs to be comparable — some elements are simply incomparable. Dependency graphs, semantic version compatibility, and file system hierarchies are all posets. The Hasse diagram is the standard picture: draw an edge from a to b whenever b covers a (a < b with nothing in between). *SQL recursive CTEs compute exactly what posets need.*

**Lattices.** A lattice is a poset where every pair of elements has a least upper bound (join, written a ∨ b) and a greatest lower bound (meet, written a ∧ b). Distributive lattices satisfy a ∧ (b ∨ c) = (a ∧ b) ∨ (a ∧ c). Type systems use lattices — subtyping forms one, and the top/bottom types are the universal bounds. Access control role hierarchies are lattices when you can combine roles meaningfully. *GraphQL's type algebra echoes lattice-like decomposition.*

**Boolean algebras.** A Boolean algebra is a distributive lattice that also has a complement operation ¬ satisfying a ∧ ¬a = 0 and a ∨ ¬a = 1. It is the algebra of AND, OR, and NOT. The set of predicates on any type T, under pointwise conjunction, disjunction, and negation, is a Boolean algebra. This is not a metaphor — it satisfies every axiom. Laws like De Morgan's (¬(a ∧ b) = ¬a ∨ ¬b) are theorems, not conventions, which means you can use them for mechanical rewriting. *The Specification pattern is this Boolean algebra made concrete.*

---

## Prolog: backtracking as combinatorial search

Prolog's execution model is depth-first search through a space of variable bindings. Every clause is a branch; unification is a constraint; backtracking is the retreat when a constraint fails. This makes it a natural fit for combinatorial problems, because the search space structure is exactly what the runtime navigates.

### Generating permutations

```prolog
permutation([], []).
permutation(List, [H|Perm]) :-
    select(H, List, Rest),
    permutation(Rest, Perm).
```

`select/3` nondeterministically picks an element H from List and returns the remainder as Rest. Prolog's backtracking then tries every possible head for every suffix, producing all n! permutations on demand. This is not a clever trick — it is a direct expression of the recursive structure of S_n: every permutation is a choice of first element followed by a permutation of the rest.

Ask for one permutation and Prolog does O(n) work. Ask for all and it does O(n · n!) work, which is unavoidable for full enumeration. Recognising the symmetric group means you immediately know the scale of that cost — and that any constraint which eliminates a prefix eliminates a whole subtree of (n-k)! completions.

### Transitive closure of a divisibility poset

Divisibility on positive integers is a partial order: 1 divides everything, primes are incomparable with most other elements, and the relation is transitive but not total.

```prolog
divides(X, Y) :- 0 is Y mod X.
below(X, Y) :- divides(X, Y).
below(X, Y) :- divides(X, Z), below(Z, Y), X \= Y.

in_interval(X, Low, High) :-
    below(Low, X),
    below(X, High).
```

`below/2` computes the transitive closure of the divisibility relation. `in_interval/3` finds all elements between Low and High in the poset — the interval [Low, High] in the Hasse diagram. On a query like `in_interval(X, 2, 12)`, Prolog finds 4, 6, and 12 (excluding 2 itself if you add `X \= Low`).

This is exactly the principal filter and principal ideal computation from order theory. Prolog just expresses it as logical inference rather than set comprehension.

The practical lesson: when you find yourself building a search with recursive backtracking, name the space you're searching. Is it a permutation space? A poset interval? A lattice? Each has associated theory — symmetry reduction for permutations, Dilworth's theorem for posets, distributivity laws for lattices — that tells you what shortcuts exist.

---

## SQL: relational algebra meets partial order

Codd's relational algebra is discrete mathematics: relations are sets, operations are set-theoretic, and queries are compositions of those operations. Recursive CTEs extend this to compute fixed points — which is exactly what poset reachability requires.

### Representing a Hasse diagram

```sql
CREATE TABLE covers (lesser TEXT, greater TEXT, PRIMARY KEY (lesser, greater));
INSERT INTO covers VALUES
    ('1','2'), ('1','3'),
    ('2','4'), ('2','6'),
    ('3','6'),
    ('4','12'), ('6','12');
```

This is the Hasse diagram of the divisibility poset on {1, 2, 3, 4, 6, 12}: each row records a covering relation, with no transitive shortcuts. The divisors of 12 ordered by divisibility form a distributive lattice — you can verify that every pair has a join and meet by inspection.

### Downward closure via recursive CTE

The downward closure of an element y (all x with x ≤ y) is the principal ideal ↓y. A recursive CTE computes it by walking cover edges:

```sql
WITH RECURSIVE below(x, y) AS (
    SELECT lesser, greater FROM covers
    UNION ALL
    SELECT b.x, c.greater
    FROM below b
    JOIN covers c ON b.y = c.lesser
)
SELECT DISTINCT y FROM below WHERE x = '2' ORDER BY y;
```

This returns 4, 6, 12 — every element above 2 in the poset. Swap the join direction and you get the principal ideal instead of the filter. The `UNION ALL` plus distinctness on the outer query is the fixed-point iteration: keep extending paths until no new pairs appear.

### Finding the join of two elements

The join of two elements a and b in a lattice is the least element above both. In SQL, that means finding common upper bounds and taking the minimum:

```sql
WITH RECURSIVE above_a(x) AS (
    SELECT greater FROM covers WHERE lesser = '2'
    UNION ALL SELECT c.greater FROM above_a a JOIN covers c ON a.x = c.lesser
),
above_b(x) AS (
    SELECT greater FROM covers WHERE lesser = '3'
    UNION ALL SELECT c.greater FROM above_b b JOIN covers c ON b.x = c.lesser
),
common_upper(x) AS (
    SELECT x FROM above_a
    INTERSECT
    SELECT x FROM above_b
)
SELECT x FROM common_upper cu
WHERE NOT EXISTS (
    SELECT 1 FROM common_upper cu2
    JOIN below b ON b.x = cu2.x AND b.y = cu.x
    WHERE cu2.x <> cu.x
)
LIMIT 1;
```

The join of 2 and 3 in the divisors-of-12 lattice is 6: the smallest element divisible by both.

Real-world poset schemas follow the same pattern. npm and Maven dependency graphs are DAGs (a special case of posets); the "compatible version" relation is a partial order; finding a consistent set of versions is a lattice operation. RBAC role hierarchies are posets where the join of two roles is the least role that has all their permissions. Version compatibility matrices in embedded systems are partial orders where recursive CTEs compute what can coexist.

---

## GraphQL: an algebraic type system (sort of)

I want to be direct here: GraphQL does not execute algebraic combinatorics computations. The connection is structural and definitional, not operational. But it is still worth naming, because understanding the type algebra helps you design schemas that reflect the combinatorial data beneath them.

GraphQL object types are product types: `type Foo { a: A, b: B }` is A × B. Union types are sum types: `union Result = Success | Failure` is Success + Failure. Lists are the free monoid over the element type. This is the same decomposition that the symbolic method in combinatorics uses to count combinatorial families: a binary tree is T = 1 + T × T (a leaf, or a root with two subtrees).

Here is a schema for exposing a poset as an API:

```graphql
type Element {
  value: String!
  covers: [Element!]!
  coveredBy: [Element!]!
  joinWith(other: String!): Element
  meetWith(other: String!): Element
}

type Query {
  element(value: String!): Element
  interval(low: String!, high: String!): [Element!]!
}
```

`covers` and `coveredBy` expose the Hasse diagram edges directly. `joinWith` and `meetWith` expose the lattice operations. `interval` corresponds to the SQL query above. The recursive structure of `Element` returning `[Element!]!` from `covers` mirrors the recursive structure of posets themselves.

The honest verdict: GraphQL is a natural interface layer for combinatorial data, and its type algebra echoes the symbolic method in a loose but non-trivial way. The connection is real enough to be useful for schema design, but it would be wrong to claim GraphQL "implements" lattice theory in any computational sense.

---

## The Specification pattern: Boolean algebra in code

The Specification pattern (Evans, Fowler) formalises business rules as first-class objects that can be composed. The mathematical content is explicit: the set of all predicates on a type T, under pointwise AND, OR, and NOT, is a Boolean algebra. Every axiom holds — commutativity, associativity, distributivity, De Morgan's laws, double negation elimination — because they hold for boolean values and pointwise operations preserve them.

This means Specification composition is not just a convenient API. It is a homomorphism into a Boolean algebra, and theorems apply.

### Rust: zero-cost combinators

```rust
pub trait Specification<T> {
    fn is_satisfied_by(&self, candidate: &T) -> bool;

    fn and<S: Specification<T>>(self, other: S) -> And<Self, S>
    where Self: Sized { And { left: self, right: other } }

    fn or<S: Specification<T>>(self, other: S) -> Or<Self, S>
    where Self: Sized { Or { left: self, right: other } }

    fn not(self) -> Not<Self>
    where Self: Sized { Not { inner: self } }
}

pub struct And<L, R> { left: L, right: R }
pub struct Or<L, R>  { left: L, right: R }
pub struct Not<S>    { inner: S }

impl<T, L: Specification<T>, R: Specification<T>> Specification<T> for And<L, R> {
    fn is_satisfied_by(&self, c: &T) -> bool {
        self.left.is_satisfied_by(c) && self.right.is_satisfied_by(c)
    }
}

impl<T, L: Specification<T>, R: Specification<T>> Specification<T> for Or<L, R> {
    fn is_satisfied_by(&self, c: &T) -> bool {
        self.left.is_satisfied_by(c) || self.right.is_satisfied_by(c)
    }
}

impl<T, S: Specification<T>> Specification<T> for Not<S> {
    fn is_satisfied_by(&self, c: &T) -> bool {
        !self.inner.is_satisfied_by(c)
    }
}
```

Because `And<L,R>`, `Or<L,R>`, and `Not<S>` are concrete structs, Rust monomorphises the composition at compile time. There is no heap allocation, no dynamic dispatch, no runtime overhead — the composed specification is as fast as the hand-written predicate.

An express-shipping eligibility rule:

```rust
struct PremiumCustomer;
struct MinimumOrder { threshold: f64 }
struct DomesticOrder;

// implement Specification<Order> for each ...

let eligible = PremiumCustomer
    .or(MinimumOrder { threshold: 1000.0 })
    .and(DomesticOrder);

let result = eligible.is_satisfied_by(&order);
```

The type of `eligible` is `And<Or<PremiumCustomer, MinimumOrder>, DomesticOrder>` — the entire Boolean expression is encoded in the type.

### C#: interface with default methods

```csharp
public interface ISpecification<T>
{
    bool IsSatisfiedBy(T candidate);
    ISpecification<T> And(ISpecification<T> other) => new AndSpec<T>(this, other);
    ISpecification<T> Or(ISpecification<T> other)  => new OrSpec<T>(this, other);
    ISpecification<T> Not()                         => new NotSpec<T>(this);
}

record AndSpec<T>(ISpecification<T> Left, ISpecification<T> Right) : ISpecification<T>
{
    public bool IsSatisfiedBy(T c) => Left.IsSatisfiedBy(c) && Right.IsSatisfiedBy(c);
}

record OrSpec<T>(ISpecification<T> Left, ISpecification<T> Right) : ISpecification<T>
{
    public bool IsSatisfiedBy(T c) => Left.IsSatisfiedBy(c) || Right.IsSatisfiedBy(c);
}

record NotSpec<T>(ISpecification<T> Inner) : ISpecification<T>
{
    public bool IsSatisfiedBy(T c) => !Inner.IsSatisfiedBy(c);
}
```

In C#, the composition goes through an interface, so dispatch is virtual. The trade-off is that you get easier integration with the rest of the ecosystem — including EF Core.

### Closing the loop with the database

```csharp
public interface IQuerySpecification<T> : ISpecification<T>
{
    Expression<Func<T, bool>> ToExpression();
}

public class PremiumCustomerSpec : IQuerySpecification<Order>
{
    public bool IsSatisfiedBy(Order o) => o.CustomerTier == Tier.Premium;
    public Expression<Func<Order, bool>> ToExpression() =>
        o => o.CustomerTier == Tier.Premium;
}

// AndQuerySpec combines two expressions via Expression.AndAlso
// EF Core translates the composed expression tree to a SQL WHERE clause
```

A composed `IQuerySpecification<T>` becomes a SQL WHERE clause. The Boolean algebra of predicates on the domain type maps directly to the Boolean algebra of SQL conditions. De Morgan's law — `NOT (A AND B) = (NOT A) OR (NOT B)` — is not just a programming convenience here; it is a rewriting rule you can apply to push negations inward, which SQL planners sometimes need help with.

The algebraic payoff is concrete: because the laws hold, you can mechanically transform specifications. Negate a complex filter by applying De Morgan's. Test a specification by testing its components and trusting the composition laws. Canonicalise a permission check by reducing double negations. These are not heuristics — they are consequences of living in a Boolean algebra.

---

## Conclusion

The four structures in this post are not exotic theory. They are the skeleton of things developers build every day:

- Search and enumeration algorithms navigate permutation spaces; recognise S_n and you know that constraint pruning is the right lever.
- Dependency graphs, version matrices, and role hierarchies are posets; recognise the partial order and recursive transitive closure becomes the natural query.
- Type systems, access control, and anything with join and meet operations are lattices; Birkhoff's representation theorem says every finite distributive lattice is isomorphic to the lattice of antichains of a poset of join-irreducibles — a non-obvious result with direct implications for canonicalising permission systems.
- Filter pipelines and rule engines are Boolean algebras; recognise the algebra and De Morgan's, double negation, and distributivity become mechanical tools for query rewriting and test generation.

Knowing the names matters because the theory is organised around them. Stanley's *Enumerative Combinatorics* is the standard reference for counting arguments. Davey and Priestley's *Introduction to Lattices and Order* covers posets and lattices with careful attention to the examples that appear in computer science. Neither requires a graduate mathematics background to get value from.

The next time you find yourself building a recursive query, a role hierarchy, or a composable filter system, ask what structure you're implementing. The answer often already has a name — and the name comes with fifty years of results attached.
