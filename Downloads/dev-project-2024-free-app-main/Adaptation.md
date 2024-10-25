# Adaptation of Conceptual Design to Flutter Mobile Application - FREE

## Overview

This document outlines the adaptations made to the original conceptual design for the FREE Flutter Mobile Application, developed as part of our Development Project. The initial design was provided by a group of designers during the System’s Analysis and Design (SA&D) block. Our development team adapted these wireframes and class diagrams to create a functional app using Flutter. The majority of these changes were made due to time constraints and a lack of comprehensive online resources to help the team implement the desired features.
Adaptations from the Original Design

## Login Options
The original design included three options for logging into the app: a standard login process, Google Sign-In, and Facebook Sign-In. Due to time constraints, we decided to exclude the Facebook Sign-In option. The rationale behind this decision was not only the limited availability of resources to implement the Facebook API but also our goal to streamline the onboarding process. By focusing on the two most commonly used authentication methods, we can improve user experience and enhance the app's overall performance.

## Removal of Media Share
The original design featured an option for users to share pictures of their memories in an Instagram-like format. However, we chose to remove this feature to prioritize the app's core functionalities and reduce cognitive overload on users. Simplifying the app helps create a more intuitive experience, allowing users to focus on essential tasks without being distracted by additional features. Additionally, the media sharing feature required significant backend support, which we determined was not feasible within our project timeline.

## Calendar Integration
The initial concept aimed to allow users to integrate multiple calendars, such as Google Calendar, Outlook, and Apple Calendar. However, due to time constraints, we limited calendar integration to Google Calendar. This decision was made because obtaining the Google Calendar API was straightforward, and ample resources were available to guide its implementation, Additionally we decided that Google Calendar was the better calendar to focus on because it is the most used calendar. By focusing on a single calendar integration, we ensure that users can still effectively manage their schedules without overcomplicating the development process.

## Profile Image
We removed the option for users to upload profile images. While this feature would have added a personalized touch to the user experience, we felt it would require considerable effort to implement and manage, particularly given the tight timeline. Instead, we opted for a default avatar system that allows users to maintain a sense of identity without complicating the development process. This choice aligns with our goal of maintaining simplicity in the app's functionality.

## Settings Page
Most features from the settings page were removed because many of the functions related to the media upload feature we had initially planned to implement. By prioritizing simplicity, we aimed to streamline the user experience and ensure that the settings remained intuitive and easy to navigate. Simplifying the settings page not only enhances usability but also allows us to allocate resources effectively to more critical areas of the application.

## Removal of Contact Integration
The feature that allowed users to add participants from their phone contacts was removed due to the complexity of its implementation and the limited time available for development. Integrating with contacts required a more extensive handling of permissions and potential security considerations, which we deemed impractical given our timeframe. As an alternative, we have provided users with the option to share events with external participants via a WhatsApp link. This solution allows users to easily invite others without the need for direct contact integration.

## Notifications 
 The team decided to remove the notifications feature because there was not enough time to implement it, and the technical requirements were quite complex. Given the project timeline and resource constraints, we chose to prioritise other core functionalities to ensure a smooth and reliable user experience.

## Closing Remarks
Throughout the development of the FREE Flutter Mobile Application, our team made several strategic decisions to adapt the original design to align with the available resources and time constraints. By prioritizing core functionalities, we managed to deliver a user-friendly and efficient application without overextending our development capacity. Although certain features were scaled back or removed, we believe these adaptations resulted in a streamlined product that still achieves the primary goals of the original concept.



