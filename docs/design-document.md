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
- EndsideOut wants to grow their ability to reach more individuals by providing a platform for asynchronous learning and engagement, while also supporting their current in-person delivery of health and wellness educational content to the students.
- EndsideOut needs the platform to meet a high standard of accessibility and usability for their audience, which includes individuals with varying levels of technical proficiency and English language skills.

### MVP Requirements
#### Student Experience
- The platform must make it easy to students to login and access content. Example constaints include:
  - A student may not have an email account 
  - A student may not be able to read or type a url given to them
  - A student may not be able to read or type (or remember) a password given to them
  - A student may only have access to a school provided device, such as a chromebook
- All content on the platform must be accessible to students with varying levels of technical proficiency and English language skills.
  - Content should be offered in multiple languages, including Spanish and English
  - Text content should have the option to hear it spoken aloud
- A student should be able to access the content for their enrolled program, including past content.

#### Administrator Experience
- The platform must allow administrators to create and manage their programs by school
  - The platform should allow pre-registering students for a program by school, and then allowing them to log in and access the content for that program
- The platform should allow administrators to create and manage content for their programs, including the ability to upload and organize content
- The platform should allow administrators to track student progress and learning outcomes, including the ability to generate aggregate reports on learning outcomes by school, program, and grade level.