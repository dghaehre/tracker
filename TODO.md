# Tracker

## MVP

Goal: get something useable out the door. Might not look pretty, but I want to be able to use it.

- [X] User specified action
- [ ] Tie an action with a competition


### Allow for "recording" a user specified action.

Setup action:

- [X] Create sql table for action
- [X] Create a page for creating a new action
- [X] Create post endpoint to handle action creation
- [X] Create endpoint for deletion of action
- [X] Create page for editing an action
  - [X] delete
  - [X] edit name
  - maybe map to competition?
- [X] create endpoint for edit of action
- [ ] Move action code to its own file

Recording:

- [X] Create sql table to "record" actions
- [X] Storage function that allows for recording
- [ ] Endpoint to allow for "record" action
- [ ] A form on user homepage for "recording" an action. Should be very easy to record!
- [ ] Add link to edit action page on user homepage

### Tie an action with a competition

- [ ] Update sql tables to allow for linking an action with a competition.
  - Any competition? invites?


### Make design great

...

Can we allow for signup without password?

