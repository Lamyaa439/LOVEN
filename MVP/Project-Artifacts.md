# LOVEN MVP Project

## Overview

LOVEN is a digital art marketplace designed to connect artists and customers through a modern and user-friendly platform. The application enables artists to showcase and manage their artwork while allowing customers to browse, favorite, purchase, and interact with artwork collections.

The project was developed using Agile Scrum practices and delivered as a Minimum Viable Product (MVP).

---

# Core Features

* Authentication and Authorization
* Artist Profile Management
* Artwork Upload and Management
* Favorites System
* Shopping Cart
* Order Management
* Notifications
* Artist Verification Requests
* Reporting System
* Responsive Mobile UI

---

# Technology Stack

## Frontend

* Flutter 3.x
* Material 3
* BLoC/Cubit State Management
* GoRouter Navigation
* Widgetbook

## Backend

* Flask
* JWT Authorization
* PostgreSQL
* Repository-Service Architecture

## Cloud Services

* Render Web Services
* Render PostgreSQL Database
* Firebase Authentication
* Firebase Cloud Messaging (FCM)
* Firebase Storage

---

# System Architecture

## Frontend Structure

```text
features/
 ├── auth
 ├── artist_profile
 ├── artwork
 ├── cart
 ├── favorites
 ├── feedback
 ├── home
 ├── navigation
 ├── notifications
 ├── order
 ├── report
 └── verification_request
```

Feature modules follow the structure:

```text
feature/
 ├── controller
 ├── data
 ├── model
 └── view
```

## Backend Structure

```text
app/
 ├── api
 ├── models
 ├── persistence
 ├── services
 ├── sql
 └── utils
```

---

# Agile Development Process

## Sprint Planning

The LOVEN MVP project was developed using Agile Scrum methodology.

Development work was divided into multiple sprints with tasks prioritized using the MoSCoW framework.

### Must Have

* User Authentication
* User Registration
* Artist Profiles
* Artwork Management
* Cart Functionality
* Favorites System
* Order Management

### Should Have

* Notifications
* Verification Requests
* Reporting System

### Could Have

* Enhanced User Experience Features
* Additional UI Improvements

### Won't Have (MVP Scope)

* Recommendation Engine
* Social Networking Features
* Real-Time Chat

### Sprint Duration

Each sprint was conducted over a two-week development cycle.

### Sprint Planning Resources

#### Jira Board

https://lamyaaalghaihab.atlassian.net/jira/software/projects/LOVEN/boards/34

#### Jira Backlog

https://lamyaaalghaihab.atlassian.net/jira/software/projects/LOVEN/boards/34/backlog

---

# Development Workflow

## Version Control Strategy

The project uses Git and GitHub for source control management.

### Branching Strategy

```text
main
└── develop
    ├── frontend/*
    ├── backend/*
    ├── feature/*
    ├── bugfix/*
    └── hotfix/*
```

### Development Process

1. Create a feature branch.
2. Implement the assigned feature.
3. Submit a Pull Request.
4. Conduct code review.
5. Merge into the development branch.
6. Perform testing and validation.
7. Deploy approved changes.

---

# Progress Monitoring

## Daily Stand-Up Meetings

The team conducted daily stand-up meetings to:

* Review completed work
* Discuss blockers
* Coordinate team activities
* Track sprint progress

## Project Tracking

Jira was used to:

* Manage sprint backlogs
* Track user stories
* Monitor issue status
* Measure sprint progress

### Metrics Monitored

* Sprint Velocity
* Planned vs Completed Tasks
* Bug Resolution Rate
* Feature Completion Rate

### Bug Tracking

https://lamyaaalghaihab.atlassian.net/jira/software/projects/LOVEN/summary

---

# Sprint Reviews

Sprint reviews were conducted at the end of each sprint to demonstrate completed features and gather stakeholder feedback.

## Sprint Reviews Document

https://github.com/user-attachments/files/28428214/Sprint.reviews.pdf

### Included Reviews

1. Sprint 1 Review – Project Foundation and MVP Planning
2. Sprint 4 Review – Firebase Integration and Cart Improvements
3. Sprint 5 Review – User Experience and Marketplace Enhancements

---

# Sprint Retrospectives

Retrospectives were conducted after each sprint to evaluate team performance and identify areas for improvement.

Topics discussed included:

* What went well
* Challenges encountered
* Lessons learned
* Process improvements

## Retrospectives Document

https://github.com/user-attachments/files/28428204/LOVEN_MVP_Retrospectives.pdf

---

# Features Delivered

## Authentication

* Firebase Authentication Integration
* Email Verification Enforcement
* JWT-Based Authorization
* Secure User Registration and Login
* Persistent User Sessions
* Firebase Cloud Messaging (FCM) Device Registration

## Artist Features

* Artist Profiles
* Profile Image Uploads
* Cover Image Uploads
* Artist Verification Requests
* Artwork Management

## Customer Features

* Browse Artwork
* Favorite Artwork
* Shopping Cart
* Order Placement

## Marketplace Features

* Order Management
* Notifications
* Reporting System
* Firebase Integration

## UI Enhancements

* Responsive Mobile Design
* Material 3 Components
* Improved Navigation Experience

---

# Final Integration and Quality Assurance

## Integration Testing

Comprehensive integration testing was performed to verify communication between:

* Flutter Frontend
* Flask Backend
* PostgreSQL Database
* Firebase Services

## Functional Testing

The following areas were tested:

* Authentication
* Artist Profiles
* Artwork Management
* Favorites
* Cart Operations
* Order Processing
* Notifications
* Verification Requests

## Testing Tools

* Postman
* Flutter DevTools
* Firebase Console
* Browser Developer Tools

---

# Testing Evidence and Results

## Authentication API Test Cases

[Auth.md](https://github.com/Lamyaa439/LOVEN/blob/develop/MVP/backend/README.md)

## Order Management API Test Cases

[Order.management.pdf](https://github.com/user-attachments/files/28428194/Order.management.pdf)

---

# Source Repository

GitHub Repository:

https://github.com/Lamyaa439/LOVEN/tree/main

---

# Production Environment

The LOVEN MVP application is deployed using Render cloud services.

## Deployment Components

### Backend Hosting

* Render Web Service

### Database

* Render PostgreSQL

### Cloud Services

* Firebase Authentication
* Firebase Storage
* Firebase Cloud Messaging (FCM)

## Deployment Architecture

```text
Flutter Application
        │
        ├── Firebase Authentication
        │
        ▼
Render Flask API
        │
        ▼
Render PostgreSQL
        │
        ├── Firebase Storage
        └── Firebase Cloud Messaging
```

## Production URL

[LOVEN Application](https://loven.onrender.com)

---

# Deliverables

| Deliverable            | Link                                                                                                            |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| Sprint Planning        | [Jira Boards](https://lamyaaalghaihab.atlassian.net/jira/software/projects/LOVEN/boards/34)                     |
| Sprint Reviews         | [Sprint Reviews.pdf](https://github.com/user-attachments/files/28428214/Sprint.reviews.pdf)                     |
| Retrospectives         | [LOVEN_MVP_Retrospectives.pdf](https://github.com/user-attachments/files/28428204/LOVEN_MVP_Retrospectives.pdf) |
| Source Repository      | [LOVEN Repository](https://github.com/Lamyaa439/LOVEN/tree/main)                                                |
| Bug Tracking           | [Jira Bug Tracking](https://lamyaaalghaihab.atlassian.net/jira/software/projects/LOVEN/summary)                 |
| Testing Evidence       | Authentication & Order Management Test Cases                                                                    |
| Production Environment | https://loven.onrender.com                                                                                      |

---

# Project Team

This project was developed by:

* Yara Alrasheed
* Lamyaa Alghaihab
* Thikera A. Ahmed
* Afnan Alkhaldi
* Alanoud Alanazi

---

# Acknowledgements

The LOVEN MVP project was developed as part of a software engineering team project following Agile Scrum practices. The project demonstrates full-stack application development, cloud deployment, collaborative version control, quality assurance, and iterative software delivery.
