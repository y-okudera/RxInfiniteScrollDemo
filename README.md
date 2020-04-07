# RxInfiniteScrollDemo
Implements loading UI and infinite scrolling.

## Setup
$ cd RxInfiniteScroll/RxInfiniteScrollDemo/_GraphQL
$ npm install

### GitHub API v4のSchemaの取得
$ cd RxInfiniteScroll/RxInfiniteScrollDemo/_GraphQL
$ node_modules/.bin/apollo schema:download --endpoint="https://api.github.com/graphql" --header "Authorization: Bearer \<GitHub Token\>"<br>
（※ \<GitHub Token\>の部分は、GitHubアカウントのトークンを入れる）

### Modelの生成
$ node_modules/.bin/apollo codegen:generate --queries=query.graphql --localSchemaFile=schema.json --target=swift ../RxInfiniteScrollDemo/RxInfiniteScrollDemo/Models/Generated/GitHubGraphQLAPI.swift
