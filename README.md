# General Info

Useful links:
- [Group GDocs](https://docs.google.com/document/d/1WRbPxzXUcYOtLToE98nsChCFKzNkyK7youcX-L81GHw/edit?usp=sharing)
- []

Item                                    | DDL
---                                     | ---
ER into a relational schema             | Sat, 23 Oct
Populate Data                           | Sat, 23 Oct
Implement procedures & triggers         | Sat, 30 Oct
Testing & Report                        | Wed, 3 Nov
**INTERNAL DEADLINE**                   | **Wed, 3 Nov**
Submission of Project Report and Code   | Sat, 6 Nov
Project Evaluation                      | Sat, 13 Nov

# Project Plan

## **Schema**: Entities

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | HealthDeclarations    | Declare                       | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | Employees             | Departments                   | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | Juniors               | Employees                     | 
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | Bookers               | Employees                     | 
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | Seniors               | Bookers                       | 
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | Managers              | Bookers                       | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Sessions              | Bookers, Meeting Rooms        | 
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | Departments           |                               | 
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | Meeting Rooms         | Departments                   | 

## **Schema**: Relations

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | Joins                 | Employees, Sessions           | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | WorksIn               | Employees, Departments        | Merge into Employees?
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | Updates               | Managers, MeetingRooms        | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Books                 | Bookers, Sessions             | Merge into Sessions?
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Approves              | Manager, Sessions             | Merge into Sessions?
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | LocatedIn             | Departments, MeetingRooms     | Merge into MeetingRooms?

## **Procedures**: Basic

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | add_department        | Departments                   | 
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | remove_department     | Departments                   | 
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | add_room              | MeetingRooms                  | "We never remove a room"
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | change_capacity       | MeetingRooms                  | “The date is assumed to be today but is given as  part of the input”
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | add_employee          | Employees                     | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | remove_employee       | Employees, Sessions           | (1) “Note that all past records should be kept intact while all future records should be removed in accordance with the specification.” => resigned_date. (2) What are future records affected here? Future Meeting (Approved & Unapproved)

## **Procedures**: Core

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/D9EAD3/000000?text=+) Tianle     | search_room           | MeetingRooms, Sessions        | "Ascending order"
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | book_room             | Sessions, Booker              | 
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | unbook_room           | Sessions, Booker              | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | join_meeting          | Sessions, Employees           | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | leave_meeting         | Sessions, Employees           | Not allowed to leave meeting that is already approved
![](https://via.placeholder.com/10/C9DAF7/000000?text=+) Simon      | approve_meeting       | Sessions, Manager             | 

## **Procedures**: Health

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | declare_health        | HealthDeclarations            | 
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | contact_tracing       | HealthDeclarations, Sessions  | 1st close contact

## **Procedures**: Admin

Assignee                                                            | Title                 | Dependencies                  | Remarks
---                                                                 | ---                   | ---                           | ---
![](https://via.placeholder.com/10/FCE5CD/000000?text=+) Teddy      | declare_health        | Employees, HealthDeclarations | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Books                 | Sessions                      | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Approves              | Sessions, Employees           | 
![](https://via.placeholder.com/10/FFF2CC/000000?text=+) Petrick    | Books                 | Sessions                      |




