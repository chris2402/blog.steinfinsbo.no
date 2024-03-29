---
layout: post
title:  "Patterns of Enterprise Application Architecture extensive summary!"
date:   2024-03-03 20:50:00 +0100
categories: debugging-daisies summary
---
# Extensive Summary of: Patterns of Enterprise Application Architecture
> 2002, by Martin Fowler

A summary written by Christer Steinfinsbø
### Table of Contents
0. [Introduction](#introduction)  
0.1 [Architecture](#architecture)  
0.2 [Enterprise Applications](#enterprise-applications)  
0.3 [Kinds of Enterprise Applications](#kinds-of-enterprise-applications)  
0.4 [Thinking about Performance](#thinking-about-performance)  
0.5 [Patterns](#patterns)  
0.5.1 [The structure of patterns](#the-structure-of-patterns)  
0.5.2 [Limitations of These Patterns](#limitations-of-these-patterns)  

Part 1 - The Narratives: 

1. [Layering](#layering)  
1.1 [The Evolution of Layers in Enterprise Applications](#the-evolution-of-layers-in-enterprise-applications)  
1.2 [The Three Principal Layers](#the-three-principal-layers)  
1.3 [Choosing Where to Run Your Layers](#choosing-where-to-run-your-layers)  
2. [Organizing Domain Logic](#organizing-domain-logic)  
2.1 [Making a Choice](#making-a-choice)  
2.2 [Service Layer](#service-layer)  
3. [Mapping to Relational Databases](#mapping-to-relational-databases)  
3.1 [Architectural Patterns](#architectural-patterns)  
3.2 [The Behavioral Problem](#the-behavioral-problem)  
3.3 [Reading in Data](#reading-in-data)  
3.4 [Structural Mapping Patterns](#structural-mapping-patterns)  
  3.4.1 [Mapping Relationships](#mapping-relationships)  
  3.4.2 [Inheritance](#inheritance)  
3.5 [Building the Mapping](#building-the-mapping)  
  3.5.1 [Double Mapping](#double-mapping)  
3.6 [Using Metadata](#using-metadata)  
3.7 [Database Connections](#database-connections)  
3.8 [Some Miscellaneous Points](#some-miscellaneous-points)  
4. [Web Presentation](#web-presentation)
4.1 [View Patterns](#view-patterns)
4.2 [Input Controller Patterns](#input-controller-patterns)
5. [Concurrency](#concurrency)
5.1 [Concurrency Problems](#concurrency-problems)
5.2 [Execution Contexts](#execution-contexts)
5.3 [Isolation and Immutabillity](#isolation-and-immutabillity)
5.4 [Optimistic and Pessimistic Concurrency Control](#optimistic-and-pessimistic-concurrency-control)
5.4.1 [Preventing Inconsistent Reads](#preventing-inconsistent-reads)
5.4.2 [Deadlocks](#deadlocks)
5.5 [Transactions](#transactions)
5.6 [ACID](#acid)
5.6.1 [Transactional Resources](#transactional-resources)
5.6.2 [Reducing Transaction Isolation for Liveness](#reducing-transaction-isolation-for-liveness)
5.6.3 [Business and System Transactions](#business-and-system-transactions)
5.7 [Patterns for Offline Concurrency Control](#patterns-for-offline-concurrency-control)
5.8 [Application Server Concurrency](#application-server-concurrency)
Part 2 - The Patterns

10. [Domain Logic Patterns](#domain-logic-patterns)  
11. [Data Source Architectural Patterns](#data-source-architectural-patterns)  

## Introduction
It starts by telling the user that computer systems are hard, 
and even more so with complexity increasing. 
We use learning to mitigate ending up in complex situations. 
The rest of the chapter sets the scope of the book and introduces base ideas.

### Architecture
He introduces "Architecture" as a concept victim of [semantic diffusion](https://martinfowler.com/bliki/SemanticDiffusion.html).
Pulling out two elements which is common or abstract enough for most definitions:
1. Highest-level breakdown of a system into its parts
2. Decisions that are hard to change

Adding that a system does (often) contain more than one architecture.

A mention of Ralph Johnsons email ([quoted in Fowler's article](https://martinfowler.com/ieeeSoftware/whoNeedsArchitect.pdf)),
where Johnson claims that architecture is "subjective" and "a shared understanding of a system's design by the expert developers on a project".

This suits well with Fowler's two points; a shared understanding on the highest-level components,
as well as subjective - as something might be perceived as hard to change, but in reality isn't, or has changed during the evolution of the project.
Also as there are many subjective definitions to architecture it is, transitively, also subjective.

Fowler then argues that it is futile to define which of the book's following Design Patterns are architectural,
as this might be subjective.

### Enterprise Applications
There are many different categories of Software Development Projects.
One of which is Enterprise Applications.
This category of applications does not often involve many paralell threads,
although it might contain challenges with [concurency](https://freecontent.manning.com/concurrency-vs-parallelism/)
It doesn't often need tight integration with hardware or other software,
but it can remote or delegate.
A common challenge in EA is complex data, and much of it.
To summarize some common challenges:
1. Persistent data  
Outlive the versions of the application, hardware and technology it runs on.
And might thus be subjective of data migration.
2. A lot of data  
There is guaranteed to either be a database, or one or more remote services that hosts a database.
All the data the system processes will (almost) guaranteed not fit in memory of the host it runs on.
3. Access Data Concurently  
Many users or systems integrate with the data, to manipulate it.
Handling concurent changes to the data must be handled.
4. A lot of User Interface Screens  
Many views for different types of data, that users with little to no technical knowledge will use.

> "Systems often have a lot of batch processing, which is easy to forget when focusing on use cases that stress
user interaction."  
**QUESTION: Does he mean UI actions that trigger Batch Processing?**

5. Integrate with other enterprise applications  
Remote calls, data translations, etc. Internal vs External  
5.6 Conceptual Dissonance  
> COMMENT: Shared concept are percieved or handled differently.
Same entity used in different departments are subjects in different concepts  
Domain Driven Design: use Context Mapping with Translation Layers and/or Anti-Corruption Layer
6. Complex Business Logic (or Business "Illogic" has Fowler calls it)

At the end Fowler points out that many misconcieve "Enterprise Applications" as huge complex applications.
However that might not be the case, as they might be a smaller application in a larger enterprise.
The reprecursions might be smaller when the application is small, but the business value is often disproportional to it's size.
Thus the cumulative effect on improving the small projects might have larger impact.
> **QUESTION: Do we agree with this last statement?**

### Kinds of Enterprise Applications
There are many problems within the field of EA.
There is no silver bullet for them all.
Fowler mentions three different types of EA:
1. B2C e-Commerce  
High availability, robust and handle concurency. 
Intuitive and accessible views for the users.
2. Automatic Learing Agreement Processing
Complicated business logic, and more complex UI.
Longer Logical Transactions for the User
> **Comment: Think Pull Requests**  
This was a poor example, 
as e-commerce is more or less expecting longer logical transactions with cached shopping cart.

3. [Simple] Expense-tracking System
A smaller application that collects vital information for the business enterprise.
Might need easy access, but high security?
> QUESTION: Not sure I understood this one. Skimmed it a bit

The patterns in this book applies to (enterprise) tools as well as the applications,
but the same "problem types" occur.

### Thinking about Performance
Build with instrumentation
Design and make it work, but don't optimize prematurely.
Measure metrics, and evaluate bottle necks.
Optimize given metrics
Measure performance boost.

1. Response Time  
Time it takes before request is complete
2. Responsiveness  
Time it takes from action is started until the user is informed something is going on.
3. Latency  
Time it takes from the action for starting the process is initiated until the process is actually started
4. Throughput  
Amount of "stuff" one can do at a given amount of time.
5. Performance  
Often; Throughput or Response Time
6. Load  
How much stress the system is under; e.g. performance given active sessions or transactions.
7. Load Sensitivity (or Degradation)  
Change in Performance given change in Load/Stress. Degradation is opostive of Load Sensitivity.
8. Efficiency  
Performance divided on the given resources.
9. Capacity  
Maximum Efficiency in total or given a threshold of performance.
10. Scalability  
Vertical/Scale-up adds more resources to a single machine.
Horizontal/Scale-out add more machines.

Design Decisions don't affect all factors equally.
And changes in design or environment might affect previous optimization boost.

### Patterns
> "Each pattern describes a problem which occurs over and over again in our environment, 
and then describes the core of the solution to that problem, 
in such a way that you can use this solution a  million times over,
without ever doing it the same way twice"  
> -- Chrisopher Alexander 

Patterns are half-baked; and designers must adapt them to their own solutions.
Patterns in this book often is connected to other patterns, 
e.g. `Class Table Inheritance`is often together with a `Domain Model`.

Most patterns in the book is truly enterprise patterns, although base patterns (Chapter 18) are more general. 
> **QUESTION: Shall we read Chapter 18 first when hitting the registry?**

#### The structure of patterns
1. Name
2. Intent & Sketch (Summary and Diagram)
3. Motivation (Problem Example/Definition)
4. How it works (Collaboration & Implementation)
5. When to use it (Application & Consequence)
6. Further Reading
7. Example

#### Limitations of These Patterns
The field is huge, and the book is written by one man 
- he could've not found and added them all.
He expects that his understanding of the books mentioned patterns will change,
and alternative solutions might occur at a later point.
The patterns are also just a starting point, and meant to be customized.

## Layering
A common way to break down software. Eg. OSI-layer, and programming language to cpu binaries via compiler layer. 
Layers should point in a direction, and be opaque - but this is no hard limit. 
Advantages 
- Isolate complexity
- Substitutability 
- Dependency minimisation
- Standardization 
- Reusability (opposite to substitute) 
Disadvantages
- Cross-cutting changes hit harder 
- Performance hit 
- Hard to find/decide what layers (and their responsability) 

### The Evolution of Layers in Enterprise Applications
Prehistoric - no layers, just file manipulation 
Client/Server architecture - initial UI/DB layers 
Domain logic
- logic in UI was hard to reuse and organize
- logic in DB was awkward  
due to limited structure mechanism
and proprietary DB hard to move procedures
> Q: What does he mean when all db's are proprietary, and how does that affect porting stored procedures? 

Object oriented solves business layer; 3 layer 
> C:(a bit hard to move to, as complexity sneaks up on you) 

Layer vs Tier 
Logical layers can run on same tier. Tiers are physical. 

### The Three Principal Layers
Presentation, Domain & Data Source 
Presentation 

1. **Presentation**  
Handles user input, and show user output. User can be human, another process or another client/server. There is a rich client and a thin client (HTML) 
> C: Rich client is a Window/Swing/fat-client in the book; which probably translates much to mobile applications as well.

2. **Data Source**  
Communicating with other systems; RPC/REST. Infrastructure in "Clean Architecture". Mainly a DB.

3. **Domain Logic**
Define domain model; implementing business policy, domain and/or business calculations and validations.  

Opaque layers; business hide all data source layer from presentation. Or less pure, when presentation access data source direct.

Presentation Multipackage; 
one package per Presentation Layers, REST API, Rich Client, Web GUI, CLI.

Data Source Multipackage; 
File data storage, Database data storage, REST API data storage.

Domain Multipackage;
>Q: Glorious Monolith? Vertical Slices?

> C: Change in "Paradigm": Human to computer user

User can be human or WS; WS -> Presentation API = Data Source API
>C: Alistar Cockburn's Hexagonal Architecture  
Ports and Adapter, Onion Architecture, Clean Architecture.

Layers can be separated in the minimum level as subroutines, or as packages at maximum.
>C: Fowler recommends this minimum

Dependency is always "down"; presentation->logic->data

Reckognize layers by "substitution thought-experiment"
> What changes if I go from DB to files or services?  
What changes if I present in CLI instead of GUI?

A fine line between beeing dogmatic and overly precautious.

### Choosing Where to Run Your Layers
What layers go on which tiers?

Logic layer on any tier; host on both, only one or split, but decide wisely for security, maintainability, usability/responsiveness!

>Q: Will he show Cross-cutting modules implementation?  

Rich Client is more forgiving to host logic layer.
Thin Client must host on server
>C: But can contain a module for validation to improve responsiveness? E.g. jQuery validation prior to sending the form.

B2C -> Generic Client & Responsiveness
Hard to update client apps.
>C: Thin clients/SPA is easier to update now adays

A challenge to use multi-tier logic layer modules for server and client is it is more and harder to maintain and update.

Splitting across is the client and server is hard; easier if it is a self-contained module that can run on both.
>C: E.g. .NET Standard 2.0 / Core Class Libraries runs on Xamarin.Forms, MAUI, WinForms (Blazor?)

More processing nodes increase complexity
Use Remote Facade and/or DTO to communicate.

Complexity Boosters:
- Distribution
- Explisitt Multithreading  
- Paradigm Chasms
- Multiplatform Development
- Exreme Performance Requirements

## Organizing Domain Logic
Describes first registry chapter: Transaction Script, Domain Model, Table Module

- **Transaction Script**  
A subroutine/Procedure does *one thing*. Subprocedures/Sub-transactions can be used; but that still should do one thing. Easy to understand, Compatible with diff. Data Source Layers (Row Data - & Table Data Gateway). Obvious transaction boundaries. Often code-duplication. 

>C: This was used by Lyse; and it got very complex!


- **Domain Model**  
Object oriented friendly. Connects Domain Entities with their respective business/domain logic and constraints.
Hard to learn, but easy to get into.

>C: Look at pictures on figure 2.1 & 2.2 to show diff between transaction script and domain model. 

>Q: Fig. 2.2 looks like it uses Strategy Pattern; How is the domain entity "Product" created with strategy pattern?

>C: Aggregates in DDD

>C: Fat model (not Anemic)

- **Table Module**  
Interface Contract to a data set, where each operation defines business logic defined for a row (or subset of rows?) on the data set.

Middleway between Domain Model & Transaction Scripts;
The Table Module represent an encapsulation of operation for a table, usually sequential operations as Transaction Scripts but isolated to a database table, view or query.

### Making a Choice
Fig 2.4 show abstract curves, effort of enhancement over complexity of domain 

Starting with transaction script is easy 
Domain model is hard 
As complexity grows ease of maintainabillity and extendability decrease. 
Steeper in transaction scripts 
Slower in domain model 
Table module is a middleway 

But changing from one to the other is hard 
>C: architectural design Patterns 


But it makes little sense to move from domain model to transaction scripts. 

Factors can lower alter the curves:
- team members experience 
- support for record sets in environment (table module) 

Patterns is not mutually exclusive - they can be combined, or live temporarily together until refractor is complete. 

### Service Layer
Splitting domain layer in two (table modules and domain model) 
The API definition of the application, or facade to the domain model. 
Suits to handle transactions and security

>Q: Is this the same as application services in DDD?

He mentions other extremes:
- transactions scripts in service layer 
- domain model entities equal to the DB tables


A middle way would be controller entity (aka. Use case controller), inspired by Jacobson ET Al. 
Fowler discourages this extra layer, and encourages to refractor to patterns that make logic reusable; such as domain model (all the way), or transactions scripts with row data gateway/active records. However, he uses it by need (not by an initial architectural decision), or at least have the thinest service layer one can

## Mapping to Relational Databases
A dominant part of Data Layer in most IS is communicating wit a database - often SQL.

### Architectural Patterns
Choice that is very influencial for the design, and difficul to refactor.  
Strongly affected by design of domain logic.  

Mitigates "awkward" interactions with DB.  
Separate SQL from Domain logic.  
>C: Database administrators use SQL for optimization.

A class per SQL Table: *Gateway*  
- Table Data Gateway  
  - Nice support Record Set
  - Fits Table Module
  - Can encapsulate Stored Procedures
  - 
- Row Data Gateway  

Domain Model;
- Not well suited for Table Data Gateway, rather use Row Data Gateway or Active Record.  
- Mismatch Domain Model and Database Schema; use Data Mapper  

The patterns are not mutually exclusive; Data Mapper can use a Gateway or Active Record to fetch data.  
The Data Mapper insulates the Business Layer from the Database
>Q: Is Data Mapper a Repository implementation in DDD?

The following works on Table, View, Stored Procedures or other Queries. Atleast for reading.  

Alternatives; 
- Object-Oriented Database Management System (OODBMS)  
- Object-Relational Mapping (ORM)

## The Behavioral Problem
ORM deals with Structural Problems.  
Reading, Writing, Transactions, Rollback, etc is Behavioral.  
Extension of this, tracking changes, Consistency in Concurrent systems, Entity/Identity tracking, etc (also behavioral).  

Unit of Work tracks transactions and consistency.  
Identity Map tracks fetched entities (and caches).  
Lazy Loading defers fetching referenced entities.  
>Q: How does Lazy Loading work in async programming?

## Reading in Data
Finders are methods that perform SQL Queries.  
Add finders in the same interface that interacts with one table.  

Row-based classes can use static finders, but these are hard to test.
>Q: What does he mean by Row-based?  

Lookout for reading objects that already exist in memory (and might be manipulated).  
Read initially in procedures.

Typical Performance Issues;
- Repeated query on a table  
  - Fetch all at once
  - Use Joins 
  >Q: Or multiple queries per DB call?
- Poorly designed Schema
  - Cooperate with DBA; analyse the SQL the queries
  - Profile & Tune

## Structural Mapping Patterns
Following patterns are not used in Table Data Gateway.  
Data Mapper might need them all.

### Mapping Relationships
RDBMS vs Object Oriented.
Linking; Primary/Foreign Keys vs Memory Reference.  
Collections; parent/owner key vs List/Array.  
Ordering; Prder the SQL query or use unordered sets for OO collections

Handle representations with an Identity Field; use the field to lookup in Foreign Key Identity Map. Cache Miss triggers Lazy Load or SQL Query.
>Q: Not sure I understand the previous statement.  
It might be that:  
- Many-to-One use Identity Map
- One-to-Many use Foreign Key Map

To mitigate complexity, meta-data mapping can be used.
>C: I believe modern ORM solves these problems, and thus no need for meta-data mapping.

Referential Integrity; handled in SQL
>C: I struggle to see the problem if one uses one transaction per procedure?

Embed Value Objects (does not need it's own table) into the table of the referring classes.
- Adding all the columns from the Value Object properties
- Store the object as a Serialized Large Object in a single column
>C: Have witnessed this in previous probject; JSON from Service was added as JSON text

LOBs are nearly impossible to query on (BLOBs more than SLOBs).

### Inheritance
No standard way for handling inheritance in relational databases.  
There are three main strategies, and they are not mutually exclusive
- Single Table Inheritance  
One large table for the whole hierarchy  
- Concrete Table Inheritance  
One table per concrete class in the hierarcy  
- Class Table Inheritance  
One table per class/abstract class/interface in the hierarchy  

The trade-offs are:
- Data redundancy and space-waste
- Access performance hit  
- Brittleness for changes 
- Data lock contention  
- Referential Integrity
- 

Fowler encourages cooperation with DBA's to evaluate which strategy suites best for a given situation, and as a rule of thumb he himselv usually starts with a Single Table Inheritance strategy due to the simplicity.  

>C: I wanted to Class Table Inheritance for `Billing/Order` in previous work, where the billing was supposed to be handled by two different external payment services. A base class would be the domain entity, and two sub-classes would implement the integration to their respective external payment service.  

## Building the Mapping
Three usual situations when mapping object model to the database:
- No defined schema; build it yourself
- Strict existing schema; reverse engineer and adapt
- Open existing schema; reverse engineer and propose changes

Simplest case:
- Low-moderate complexity
- Build schema yourself
Build proper schemas and use Transaction Scripts or Table Module for domain logic. Row or Table Gateway for SQL connection (or ORM).

Pitfall when using Domain Model;  
- Design domain model in isolation from database.  
If it is a mismatch, use Data Mapper (even if complex). Isomorphic models schema design to object model; use Active Record.  
- Domain Model changes must be integrated and tested often to database mapping  
Changes can have large performance hit, and be hard to refactor.

Existing Schemas use same steps when deciding;
- High Complexity -> Domain Model  
Data Mapper is often used as it is usually a mismatch between domain model and schema  
- Low/Moderate Complexity -> Row/Table Data Gateway mimics database

### Double Mapping
Multiple Data Sources, one can use Multiple Mapping Layers.  
Consider two-step mapping scheme if the data sources are similar, but again extensively different from domain model; 
1. Convert data from Domain to logical data store  
The logical data store maximizes the similarities to the data sources
2. Convert logical data source to the concrete data source models

## Using Metadata
Code generation or Reflection based on Metadata-files to describe the mappings. 
>C: I assume this is similar to EF-Attributes? JSON/XML Serialization Attributes?
This avoids much boilerplate/hand-written mapping.

This approach suites well with Query Object pattern, which abstracts out SQL.  
Fowler extends this by claiming this suites well with Repository pattern.

## Database Connections
Database Connection Management; when to open, when to close, and how to optimize them.
Connections can be viewed as resources just like memory.  

Record Sets can be "Disconnected" or "Connected".  
Disconnected Record Set does not need the same connection for reading as writing.  
A connected does.  

Transactions must have an open connection through-out it's lifetime.

Connection pooling can optimize usage, as establishing a connection can be expensive. Use a Connection Manager!

Releasing a connection can be done via a registry if it is not closed within the same scope where it was captured.

One can auto-close connection via the Garbage Collector; A procedural Transaction Scope or similar.  

Transactions can handle it's own connection; and this suites well with Unit of Work pattern.

Non-transactional request; reading data that is not going to be mutated, one can do it in a fresh connection - let pooling handle the short-lived connection.
>Q: Not sure I understood this statment.

Disconnected Record Sets that does not use transaction, and a potential different connection after manipulation, must handle concurency problematique.

## Some Miscellaneous Points 
Named Column Indices may be slower, but positional indicies may fail if the schema changes and the SQL Query uses asterisk (*) for the SELECT clause.

Precompiling SQL can be an advantage.
>C: EF Does not, but uses different methods to optimize

Multiple Queries per database call


# Web Presentation
Can be many "programs" per web-server
These web-programs are mainly architected: Scripts or Pages
Scripts: Functions that handle HTTP-Request messages and create HTTP-Response messages
- Handles request well
Pages: Simplification for writing HTML, that can interpolate data from the context
- Handles response well
Can be combined for optimal segregation
[Razor Pages: Code-behind are scripts]
**MVC**
- Controller (Script) handles input, View (Pages) handles response
[C: Martin calls it Input Controller in MVC to specify]
Input Controller recieves request, and delegates to *model*, which is any form of application layer. Perhaps a **Application Controller** 

## View Patterns
Template View: JSP, aspx, Razor-Template
Transform View: XSLT or [JSLT](https://github.com/schibsted/jslt) (SCHIBSTED!)

Two-step view: Components and/or Layout pages for reuse?

## Input Controller Patterns
Input controller can be separated per page, Page Controller
[Q: 1 controller per Vertical Slice?]

Input controllers handle HTTP Request & Decide what do to with them
[C: Handling HTTP Request is more pushed into the framework now; Middleware and Filters in ASP.NET (Routing & Model Binding assisting)]

# Concurrency
Hard to reveal concurrent problems and hard to test for.
Enterprise Apps have a lot of concurrency; use transactions to mitigate.
Offline concurrency; occurs over many transactions and is thus not handled with one transaction
Concurrency in application servers running paralell threads

## Concurrency Problems
Control mechanism for Concurrency can create new problems on their own.
**Lost Updates**: When two agents read out same version and manipulate them concurrently. The last to save wins
[C: Race condition]
**Inconsisten Read**: When one agent is aggregating from a dataset by sequential reading, and middle of process the dataset is updated - the aggregation may be incorrect.

Both problems cause problems of *correctness* (safety)
Correctness vs *Liveness*

Control Mechanisms mitigate the problems, but often cause problems of their own: *No free lunch*

## Execution Contexts

## Isolation and Immutabillity
## Optimistic and Pessimistic Concurrency Control
### Preventing Inconsistent Reads
### Deadlocks
## Transactions
## ACID
### Transactional Resources
### Reducing Transaction Isolation for Liveness
### Business and System Transactions
## Patterns for Offline Concurrency Control
## Application Server Concurrency
