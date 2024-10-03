
```markdown
# ParadeDB

ParadeDB is a PostgreSQL-based database optimized for full-text search and similarity (vector) search. This guide will help you quickly set up ParadeDB using Docker Compose and explore some of its key features.

## Getting Started

### Run ParadeDB with Docker Compose

To start ParadeDB with Docker Compose, use the following command:

```bash
docker-compose up -d
```

This will pull the ParadeDB image and run the container.

### Accessing the Database

Once the container is up, you can access the PostgreSQL database using the following command:

```bash
docker exec -it paradedb psql -U postgres
```

Alternatively, you can use **pgAdmin** (included in the Docker Compose file) to connect to the database via the browser for easier management.

## Quickstart Guide

This section will guide you through basic usage, including full-text search and similarity (vector) search in ParadeDB.

### Full Text Search

ParadeDB comes with a helpful procedure that creates a table populated with mock data to help you get started. Once you're connected to the database via `psql`, you can run the following commands:

1. Create a table with mock data:

   ```sql
   CALL paradedb.create_bm25_test_table(
     schema_name => 'public',
     table_name => 'mock_items'
   );
   ```

2. Inspect the table:

   ```sql
   SELECT description, rating, category
   FROM mock_items
   LIMIT 3;
   ```

### Creating a BM25 Index

Next, let’s create a BM25 index called `search_idx` on the `mock_items` table. BM25 is a ranking function used by search engines to estimate the relevance of documents to a query.

```sql
CALL paradedb.create_bm25(
  index_name => 'search_idx',
  table_name => 'mock_items',
  key_field => 'id',
  text_fields => paradedb.field('description') || paradedb.field('category'),
  numeric_fields => paradedb.field('rating'),
  boolean_fields => paradedb.field('in_stock'),
  datetime_fields => paradedb.field('created_at'),
  json_fields => paradedb.field('metadata')
)
```

### Executing Full Text Search

Now, let’s perform a full-text search to find items that match specific criteria.

1. Search for items where the `description` contains "keyboard" or the `category` contains "electronics", and the rating is greater than 2:

   ```sql
   SELECT description, rating, category
   FROM search_idx.search(
     '(description:keyboard OR category:electronics) AND rating:>2',
     limit_rows => 5
   )
   ```

2. Execute a phrase search for "bluetooth speaker" with flexibility (slop operator `~1` allows one word in between):

   ```sql
   SELECT description, rating, category
   FROM search_idx.search('description:"bluetooth speaker"~1');
   ```

### Highlighting Search Results

ParadeDB allows you to highlight search terms in the results. For example, you can highlight the term "bluetooth" in the description:

1. Generate highlighted snippets:

   ```sql
   SELECT * FROM search_idx.snippet(
     'description:bluetooth',
     highlight_field => 'description'
   );
   ```

2. Join the snippet with the `mock_items` table to view the original data alongside the highlighted results and BM25 scores:

   ```sql
   WITH snippet AS (
       SELECT * FROM search_idx.snippet(
         'description:bluetooth',
         highlight_field => 'description'
       )
   )
   SELECT description, snippet, score_bm25
   FROM snippet
   LEFT JOIN mock_items ON snippet.id = mock_items.id;
   ```

## Additional Features

ParadeDB also supports:
- **Similarity (vector) search** for high-performance searches across large datasets.
- **Advanced indexing techniques** for optimizing queries that involve multiple data types (text, numeric, boolean, etc.).

For more detailed documentation, visit [ParadeDB Docs](#).

---

This guide should help you get started quickly with ParadeDB. Explore the capabilities of full-text search and other advanced features to enhance your application's search functionality.
```
