# LOVEN — Project Charter

## App Purpose
The purpose of LOVEN is to develop a mobile marketplace that enables artists to create profiles, showcase their artwork, and sell it to users interested in art in a simple and organized way. In its initial stage, the platform allows users to browse artworks, discover artists, complete purchases, and follow basic order and shipping updates through a user-friendly mobile experience.

---

## Objectives
- Develop an MVP mobile application that enables artists to create accounts, build profiles, publish artwork listings with pricing details, and manage incoming orders by the end of the project period.
- Provide users with a simple and user-friendly mobile experience that allows them to browse artworks, explore artist profiles, save favorites, manage a persistent cart, and complete purchases in the initial release.
- Deliver the first version of the app in English while supporting basic trust and order-support features such as optional artist verification and shipment information updates.

---

## Stakeholders

### Internal Stakeholders
- Team Members: Responsible for planning, designing, developing, documenting, and delivering the project.
- Supervisor: Provides feedback, guidance, and evaluation throughout the project.

### External Stakeholders
- Artists – Use the platform to create profiles, publish artwork, manage orders, and potentially request verification.
- Users Interested in Art – Browse artworks, save favorites, place orders, and request custom pieces.
- Future Platform Administrators – May manage verification reviews, content moderation, and operational support in future stages.

---

## Team Roles

| Name | Role |
|------|------|
| Lamyaa Alghaihab | Backend Developer, Testing, Documentation, and Managing a GitHub repository and pull requests (PRs) to setting up a collaborative environment, enforcing code quality, and following a structured workflow for changes. |
| Yara Khalid Alrasheed | Backend Developer, Testing, Documentation, and Project Planning. |
| Thikera A. Ahmed | Backend Assistance and Mobile App Developer, Testing, and Documentation |
| Alanoud Naif Alanazi | Mobile App Developer and UI Design, Testing, Documentation, and Progress Tracking. |

---

## In-Scope
The initial scope of LOVEN includes the design and development of a bilingual mobile marketplace application that supports the core buying and selling experience between artists and users interested in art.

The following items are included in scope for the initial release:
- Mobile application development for the first version of the platform.
- User registration, login, and basic account management.
- Artist profile and portfolio creation and management.
- Artwork listing creation and management, including title, description, images, price, available quantity, and shipping fee.
- Artwork browsing and viewing for users.
- Purchase functionality for listed artwork.
- Persistent shopping cart functionality.
- Favorites or wishlist functionality for saving artworks.
- Artist dashboard for viewing orders and updating order status.
- Manual shipment information updates by the artist, including shipping company and tracking number.
- User access to order and shipment information for follow-up.
- Product reporting functionality for users to report problematic or inappropriate listings.
- A suggestions or feedback form for users to submit recommendations to the platform management.
- English language support.
- A unified account model where artists can also purchase artworks from other artists as regular users.
- Optional artist verification process based on submitted supporting documents, with a verification badge shown on the artist profile if approved.

---

## Out-of-Scope
The following items are not included in the initial scope of LOVEN and may be considered for future phases:
- Web application development; the initial release is mobile only.
- Direct integration with shipping providers or automatic shipment creation.
- Real-time in-app shipment tracking from shipping carrier systems.
- Auction and bidding functionality for artwork sales.
- Workshops, galleries, and exhibitions modules.
- Advanced social and community features such as posts, comments, follower systems, and social feeds.
- International payment support.
- Multi-currency support; the initial release will use local currency only.
- Support for languages other than English.
- Special order request functionality, allowing users to submit custom requests to artists and receive a price quotation for approval or rejection.

---

## Risks and Mitigation

| Risk | Mitigation |
|------|-----------|
| Limited team experience with key development tools such as Flutter and GitHub workflow may delay development and increase rework. | Schedule early training sessions, assign time for guided learning, divide responsibilities based on each team member’s strengths, and prototype critical technical components early. |
| Integration complexity between the mobile app, backend logic, order management, and testing may lead to delays or an incomplete MVP by the deadline. | Break development into smaller milestones, test core workflows early, hold regular progress reviews, and prioritize completion of essential user journeys before secondary features. |
| Data loss or backend/database failure may result in loss of user accounts, artwork data, or order information. | Use a reliable backend solution, implement regular backups, and test data handling and storage processes carefully. |
| Critical bugs in core functionalities such as user authentication, artwork listing, or order placement may prevent users from using the application. | Perform thorough testing of core user flows, implement validation and error handling, and conduct continuous testing throughout development. |
| APIs between the mobile app and backend may not function correctly, causing major features (login, orders, listings) to fail. | Define clear API structure, test endpoints early, and integrate features incrementally. |
| Incorrect database design may lead to data inconsistency, broken features (orders, listings), or inability to scale the system. | Carefully design and review database schema early, test data flows, and validate relationships between entities. |

---

## High-Level Plan

| Stage | Timeline | Main Focus | Key Deliverable / Milestone |
|------|--------|-----------|-----------------------------|
| Idea Development | Week 1–2 | Define the project idea, identify the problem, and align the team around the concept | Project idea selected and approved |
| Project Charter Development | Week 3–4 | Define the project purpose, objectives, scope, risks, stakeholders, and high-level plan | Project Charter completed |
| Technical Documentation | Week 5–6 | Prepare the system architecture, UML diagrams, technical design, and supporting documentation | Technical documentation finalized |
| MVP Development | Week 6–10 | Build the first version of the mobile application with core marketplace features | MVP completed and tested |
| Project Closure | Week 11–12 | Perform final testing, prepare the final presentation, and complete project submission and closure activities | Final presentation and project closure completed |

## Project Charter (Word Document)
- 📝 [Project Charter (Word)](https://github.com/user-attachments/files/26645604/LOVEN.-.Project.Charter.Development.-.final.docx)
- 📝 [Project Charter (PDF)](https://github.com/user-attachments/files/26645622/LOVEN.-.Project.Charter.Development.-.final.pdf)
