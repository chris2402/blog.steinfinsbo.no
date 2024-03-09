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
4. []()  
5. []()  

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

