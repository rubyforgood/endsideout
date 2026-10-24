# EndsideOut LMS Design Document

## Goals

This system aims to provide EndsideOut a custom Learning Management System to:
- Streamline their existing in-person delivery of health and wellness educational content to the students
- Provide a centralized platform for managing the data they used to track learning outcomes, so they can generate reports needed to provide to their funders
- Grow their ability to reach more individuals by providing a platform for asynchronous learning and engagement so they are not limited by their ability to staff and travel to deliver content in person

## Context

### Why a custom platform?
- EndsideOut initially attempted to use an off the shelf LMS, but found that it did not work well for their audience's needs and did not provide the flexibility they needed to manage their content and track learning outcomes.
  - Too complex for students with low literacy
  - Too complex for an in person delivery model
  - Too complex for using with students without email accounts
  - Too many features that were not needed for their use case, which made it difficult to use and maintain
- EndsideOut has a technical team that wants to be able to deeply integrate existing custom games and other content into the LMS
- EndsideOut needs the platform to meet a high standard of accessibility and usability for their audience, which includes individuals with varying levels of technical proficiency and English language skills.

### MVP Requirements
#### Student Experience
The platform prioritizes student accessibility.

- Student accounts must not depend on having an email address
- Students must not be required to read or type a url
- Students must not be required to read, type, or memorize a password
- We do not assume a given student will have permanent access to a specific computer
- All content on the platform must be accessible to students of any level of technical proficiency
- Content must be offered in multiple languages, including Spanish and English
- A student should always have the option to hear text content spoken aloud
- A student should be able to access all content, past and present, for their enrolled program

#### Administrator Experience
- Administrators are EndsideOut staff who have access to all schools and the curricular content management. School staff (teachers or administrators) do not have access to the admin experience. TBD what their level of access will b. 
- The platform must allow administrators to create and manage their programs by school
  - The platform should allow pre-registering students for a program by school, and then allowing them to log in and access the content for that program
- The platform should allow administrators to create and manage content for their programs, including the ability to upload and organize content
- The platform should allow administrators to track student progress and learning outcomes, including the ability to generate aggregate reports on learning outcomes by school, program, and grade level.