# Dealfront Test Assignment

## Updates after Dealfront review

### What we liked

- Very good README included
- Meets the functional requirements from the specification
- Good test coverage, acceptance and integration
- Nice to see TypeScript used
- Responsive design implemented
- Access token entered via .env file, and .env.example file provided

### What we'd like to see improved

- > Styling some elements by HTML tag name rather than classes

    **[+]** only global reset styles are applied to elements, all others apply to class names

- > Performing some testing assertions using HTML tag names rather than always sticking with ember-test-selectors

    **[+]** all queries done with `data-test-*` selectors

- > Setting `innerHTML` on parts of the template from the component and using methods like `classList.toggle`, rather than relying on tracked properties to control different template states

    **[+]** reworked approach with `BranchesRow` component and custom modifier triggering branches API call on a first render. As a sideeffect: only single row of branches at a time can be visible, if user clicks on another repository row, the row with branches for a previous one collapses

- > Using `data-test-*` selector for selecting elements in the component, rather than only using those selectors for test environments (`data-test-*` selectors are removed from production builds by default which can potentially cause issues)

    **[+]** my bad: reworked solution with Ember approach by introducing `BranchesRow` component

- > If an invalid access token is used and the app fails to load any repos, it does not seem to communicate the problem to the user (saw that ember-cli-notifications was installed, but it doesn't seem to show that error for us)

    **[+]** added 401 error check

## Decisions Explained

### Intro

I had two approaches at my disposal:

1. Build an app quickly with familiar but older conventions (the setup I used to work on my previous project):
   - glimmer
   - co-located components with `.js` and `.hbs` files
   - Broccoli.js build tool
   - `npm`, or:

2. Invest more time in building the app and learning the latest recommended practices, including:
   - first-class component templates
   - Embroider build system
   - TypeScript
   - `pnpm`

Based on my experience, investing efforts into learning and implementing the latest practices always pays off by:

- pushing off a technical debt piling up soon enough
- the codebase is more stable, free from deprecations, and with security support from Ember LTS versions

### Implementation

1. **I experimented with the following Ember app setup**
   - **Polaris** edition: `ember-source@v~6.2.0`
   - **Embroider** build system
   - written with **TypeScript**
   - components are defined in `.gts` and use `<template>`
   - no `ember-data`

2. **Third-party addons used and ~~not used~~**

   I followed the approach of using as few dependencies as necessary to complete the task.
   1. `ember-cli-dotenv` - for shielding sensitive data
   2. `ember-concurrency` - for handling REST API calls, loading state, and error management
   3. `ember-test-selectors` - for testing convenience on querying elements
   4. `ember-cli-notifications` - for notifying errored API calls
   5. `ember-truth-helpers` - `eq` helper used in `components/repos/filter.gts` template

   I also considered other addons, but I got away with browsers widely supported **The HTML DOM API**

   1. *Forms and Validation:*

      [ember-headless-form](https://github.com/CrowdStrike/ember-headless-form) < **HTML forms with native form validation**

   2. *Styling:*

      [Tailwind CSS](https://tailwindcss.com/docs/installation/framework-guides/emberjs) / [ember-bootstrap](https://www.ember-bootstrap.com/) < **CSS**

   3. *Handling data:* `ember-data`

3. **`ember-cli-dotenv`**

    To keep sensitive data from publishing to a remote repository, I introduced `.env` for environment variables:

    - GitHub PAT (Classic) is stored in `GITHUB_PAT_CLASSIC`
    - `.env` should be handled locally only
    - `.env.example` - is available in the remote repository with all used environment variables (in our case - just one)
    - `GITHUB_PAT_CLASSIC` is set in `development` and `test` environments only

4. **No `ember-data`**
    - the app is not modifying any received data - it just displays the data it gets
    - I understand that for demonstrating my expertise, it would be better to use `ember-data`, although due to the deprecation of adapters & serializers paradigm and encouragement to switch to `Handlers` with `RequestManager`, I chose to ditch `ember-data` completely, rather than invest more time into mastering `RequestManager`

5. **A single `application` route is used for simplicity:**
    - **the drawback**: the state is NOT persistent on page reload
    - for a state-preserving solution, I would use a route `repo/:repo_name` with `ember-data` models `repository` & `branch` with a relationship: repository `hasMany` branches
    - for filtering, I would use route `queryParams`, as well as would add a pagination support

6. **Repositories filtering**
   - filters are implemented via radio groups
   - filters handle `null` value on `language` type
   - `All` is a default value for both `language` and `privacy` filters. Thus all repositories are listed initially

7. **Styling**
   - I decided to use minimal design, no fancy looks, no external libraries, just plain functionality, and minimum CSS
   - each repository row is clickable and behaves like a drawer for the row below with a branches list
   - implemented responsive design: supports desktop and mobile views
   - icons are taken from [AmpWhat](https://www.amp-what.com/)

8. **App functionality decisions**
   1. No excess, duplicate, or unnecessary API calls:
      - disabling `find org repos` button while API call in-flight
      - checking in `toggleBranchRow` if branches were already retrieved from API call
      - setting `getRepoBranches` task droppable
  
   2. Reset logic:
      - filters are reset on a new org API call

9. **REST API calls**

    The task requires showing a column with the total number of branches. The `org/repos` API is not returning any data related to branches. There is a separate `repo/branches` endpoint. I am not calling it after the repositories list is rendered, as doing 30 calls at once doesn't make much sense in our case:
      - branches list is hidden from a view initially
      - the data is displayed on user interaction, so data is fetched only when and which needed

10. **Testing**
    - `ember-concurrency` and tests do not play very nice. In particular, I failed to write a test scenario for checking the loading state while API calls are in flight

## Prerequisites

You will need the following things properly installed on your computer.

- [Git](https://git-scm.com/)
- [Node.js](https://nodejs.org/)
- [pnpm](https://pnpm.io/)
- [Ember CLI](https://cli.emberjs.com/release/)
- Last 1 version of either browser: [Google Chrome](https://google.com/chrome/) // [Mozilla Firefox](https://www.mozilla.org/en-US/firefox/new/) // [Safari](https://support.apple.com/en-us/102665)

## Installation

- `git clone <repository-url>` this repository
- `cd dealfront`
- `pnpm i`

## Running / Development

Before starting the app, assign your GitHub account PAT (classic) into the `GITHUB_PAT_CLASSIC` environment variable in `.env`.

When creating a `.env` file, make a copy from `.env.exmaple`.

- `pnpm start`
- Visit your app at [http://localhost:4200](http://localhost:4200).
- Visit your tests at [http://localhost:4200/tests](http://localhost:4200/tests).

### Running Tests

- `pnpm test`
- `pnpm test:ember --server`
