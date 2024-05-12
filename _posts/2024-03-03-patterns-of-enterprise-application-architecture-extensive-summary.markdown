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


{% comment %}
<!-- 
// TODO: Write summary on this 
6.[Session State](#session-state)
7.[Distributed Strategies](#distributed-strategies)
8.[Putting It All Together](#putting-it-all-together)
-->
{% endcomment %} 


Part 2 - The Patterns

{% comment %}
<!-- 
// TODO: Write summary on this 
9. [Domain Logic Patterns](#domain-logic-patterns)  
-->
{% endcomment %} 
10. [Data Source Architectural Patterns](#data-source-architectural-patterns)  

# Part 1 

{% include_relative .PEAA_SUMMARY/00.Intro.md %}
{% include_relative .PEAA_SUMMARY/01.Layering.md %}
{% include_relative .PEAA_SUMMARY/02.OrganizingDomainLogic.md %}
{% include_relative .PEAA_SUMMARY/03.MappingToRelationalDatabases.md %}
{% include_relative .PEAA_SUMMARY/04.WebPresentation.md %}
{% include_relative .PEAA_SUMMARY/05.Concurrency.md %}

{% comment %}
<!-- 
  TODO: Write summary on this
  {% include_relative .PEAA_SUMMARY/06.SessionState.md %}
  {% include_relative .PEAA_SUMMARY/07.DistributedStrategies.md %}
  {% include_relative .PEAA_SUMMARY/08.PuttingItAllTogether.md %}  
-->
{% endcomment %} 

# Part 2 

<!-- TODO: Write summary on this -->
{% include_relative .PEAA_SUMMARY/09.DomainLogicPatterns.md %}


{% include_relative .PEAA_SUMMARY/10.DataSourceArchitecturalPatterns.md %}
