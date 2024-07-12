[![CI] (https://github.com/archanaRacha/AE-Feed/actions/workflows/CI.yml/badge.svg)] (https://github.com/archanaRacha/AE-Feed/actions/workflows/CI.yml)

## Narrative #1
-> as an online customer
I want the app to automatically load my latest image feed so I can always enjoy the newest images of my friends.

## Scenarios (Acceptance criteria)
Given the customer has connectivity
-When the customer requestes to see their feed
-Then the app should display the latest feed from remote and replace the cache with the new feed

## Narrative #2
-> As an offline customer

I want the app to show the latest saved version of my image feed so I can always enjoy images of my friends.

## Scenarios (Acceptance criteria)

Given the customer doesn't have connectivity
And there is a cached version of the feed
And the cache is less than seven days old
When the customer requests to see the feed
Then the app should display the latest feed saved

Given the customer doesn't have the connectivity
And there is a cached version of the feed
And the cache is empty
When the customer requests to see the feed
Then the app should disply an error message

## Use Cases

## Load Feed From Remote Use Case

## Data:
- URL

## Invalid data -error course (sad path):
1. System delivers invalid data error.

## Load Feed From Cache Use case

## Primary course:
1. Execute "Load Image Feed" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates feed items from cached data.
5. System delivers feed items.

## Retrieval Error course (sad path)
1. System delivers error.

## Expired cache course (sad path):
1. System delivers no feed items.

## Empty cache course (sad path):
1. System delivers no feed items.

## Validate Feed Cache Use case

## Primary course:
1. Execute "Validate cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.

## Retrieval Error course (sad path)
1. System deletes cache.

## Expired cache course (sad path):
1. System deletes cache.

## Cache feed use case
## Data:
- Feed items

## Primary course (happy path):
1. Execute "Save feed Items" command with above data.
2. System deletes the old cache data.
3. System encodes feed items.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

## Deleting error course (sad path):
1. System delivers error.

## Expired cache course (sad path):
1. System deletes cache.
2. System delivers no feed items.

## Empty cache course (sad path):
1. System delivers no feed items if the cache is empty.

## Cache feed Use Case
## Data:
-Feed items

## Primary course (happy path):
1. Execute "save feed Items" command with above data.
2. System deletes old cache data.
3. System encodes feed items.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

## Deleting error course(sad path):
1. System delivers error.

## Saving error course (sad path):
1. System delivers error.

## Flowchart
------------------

- Retrieve
    - Empty cache returns empty (before something is inserted)
    - Empty cache twice returns empty (no side-effects)
    - Non-empty cache returns data
    - Non-empty cache twice returns same data (retrieve should have no side-effects)
    - Error returns error(if applicable, e.g., invalid data)
    - Error twice returns same error (if applicable, e.g., invalid data)

Insert
    - To empty cache works
    - To non-empty cache overrides previous value
    - Error (if possible to simulate, e.g., no write permission)




- Delete
    - Empty cache does nothing (cache stays empty and does not fail)
    - Inserted data leaves cache empty
    - Error (if possible to simulate, e.g., no write permission)

- Side-effects must run serially to avoid race-conditions (deleting the wrong cache... overriding the latest data...)