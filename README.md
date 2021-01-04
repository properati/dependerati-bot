# Pull request on release 
This Github Action is that send pull request on bundle update.  

This Github Action is running on **[ruby2.6-alipne](https://github.com/docker-library/ruby/blob/5c9e21cbf79b7f36d505555c9ecd62cf0f7e07f8/2.6/alpine3.10/Dockerfile)**.

## Usage
※ Without Gemfile and Gemfile.lock, this workflow is failure. 

```
name: create prs on depending repos when releasing a tag 
on:
  push:
    tags:
      - '*'

jobs:
  notify-dependants:
    name: notify dependants 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v1
        with:
          fetch-depth: 1
      - name: notify dependants 
        uses: properati/dependerati-bot@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          git_user_name: example_name
          git_email: test@example.com
          reviewers: test,test1,test2 // optional
          bundler_version: 2.0.1 // optional
```

## License
The plugin is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
