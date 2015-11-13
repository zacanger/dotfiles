title: Checklist for your new Open Source JavaScript Project
tags:
  - open-source
  - javascript
date: 2015-09-27 17:13:15
---


![Open-source JavaScript](http://i.imgur.com/fIeyz2I.png)

In this post, I'll synthesize the lessons passed by [Kent C. Dodds](https://twitter.com/kentcdodds) in his series "How to Write an Open Source JavaScript Library". Check his course on [egghead.io](https://egghead.io/series/how-to-write-an-open-source-javascript-library). 

After watching that (**excellent**) course, you can use this checklist to quickly refresh your mind and remember each step that you need to do in order to create your next open source project.

## Checklist

- **Prefer to write a micro-library**. Benefits:
  - More easy to reason about
  - More easy to test
  - More easy to reuse

- **Create a repository for your libray**:
  - Go to your git repository hosting service (here we'll use [GitHub](https://github.com/))
  - Create a new repository
  - Create a README file
  - Clone your repository to your local machine
    ```shell
    git clone git@github.com:YOUR_USER_NAME/YOUR_REPOSITORY_NAME
    ```

- **Ensure that you have [Node.js](https://nodejs.org) installed**.

- **Set NPM properties**:
  ```shell
  npm set init-author-name 'Your name'
  npm set init-author-email 'Your email'
  npm set init-author-url 'http://yourdomain.com'
  npm set init-license 'MIT'
  ```

- **Save modules with an exact version**:
  ```shell
  npm set save-exact true
  ```

- **Login with your NPM account on terminal**:
  ```shell
  npm adduser
  Username: YOUR_USER_NAME
  Password: YOUR_PASSWORD
  Email: YOUR_EMAIL@domain.com
  ```
  
- **Create a `package.json`**:
  ```shell
  npm init
  ```

- **Create the main file**:
  - Create the `src/index.js` file that will expose all the module's functionalities.
  ```js
  module.exports = {
    funcOne: funcOne,
    funcTwo: funcTwo
  };
  ```

- **PROTIPs**:
  - Install and save modules: `npm i -S module-name` is equal to `npm install --save module-name`
  - Install and save dependency modules: `npm i -D module-name` is equal to `npm install --save-dev module-name`

- **Add a .gitignore file**

- **Push your changes to GitHub**

- **Publish to NPM**: `npm publish`

- **Releasing a version to GitHub**
  ```sh
  git tag 1.0.0
  git push --tags
  ```
  - Go to *releases* on GitHub
  - Draft a new release

- **Releasing a new version to NPM**:
  - Based on the type of change that you did in your code, you should bump the version of your module.
  - Use [Semantic Versioning](http://semver.org/) to bump the version correctly
  - Commit the code `git add` & `git commit`
  - Add a new tag `git tag 1.1.0`
  - Push to GH (GitHub) `git push`
  - Push the tags `git push --tags`
  - Republish to NPM `npm publish`
  - See if all is okay `npm info <your-module-name>`

- **Publishing a beta version**:
  - Do some stuff in your code
  - Bump the version with the sufix `-beta.0`. **Ex**: `1.3.1-beta.3`
  - Commit the code `git add` & `git commit`
  - Add a new tag `git tag 1.1.0`
  - Push to GH (GitHub) `git push`
  - Push the tags `git push --tags`
  - Publish to NPM with **--tag beta** . **Ex**: `npm publish --tag beta`
  - See if all is okay. `npm info <your-module-name>`
  - How to install a beta version: `npm install <module-name>@beta` (latest beta) or `npm install <module-name>@1.3.1-beta.3` (specific version)

- **Setting up Unit Testing with Mocha and Chai**:
  - Install mocha and chai `npm i -D mocha chai`
  - Create your test file `src/index.test.js` or `src/index.spec.js`
  - Update package.json `"test": "mocha src/index.test.js -w"`
  - Run `npm test`

- **Automating Releases with semantic-release**:
  - Install semantic-release `npm i -g semantic-release-cli`
  - Setup semantic-release `semantic-release-cli setup`
  - Setup your CI configuration file to run the tests before run semantic-release.
    - Ex: `.travis.yml`
    ```
    # some stuff here

    before_script:
      - npm prune
    script:
      - npm run test
    after_success:
      - npm run semantic-release
    ```
   
- **Writing conventional commits with commitizen**:
  - [Angular git commit guidelines](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit) 
  - `npm i -D commitizen cz-conventional-changelog`
    - **commitizen**: allows to write commit messages
    - **cz-conventional-changelog**: Ask questions to generate the commit
  - Add commitizen in npm scripts: 
    ```json
    "script": {
      "commit": "git-cz"
    }
    ```
  - Configure **commitizen** to use **cz-conventional-changelog**. In `package.json`, add the following property:
    ```json
    "czConfig": {
      "path": "node_modules/cz-conventional-changelog"
    }
    ```
  - **ps**: I got a problem with the version 1.1.1 and 1.1.0 of the cz-conventional-changelog, [and other people too](https://github.com/commitizen/cz-conventional-changelog/issues/6). To fix it, I installed the version **1.0.1**, and worked properly.
    ```sh
    npm install cz-conventional-changelog@1.0.1 -D
    ```
  - Using commitizen:
    - Add your changes `git add`
    - `npm run commit`
      - Choose the type of changes that you did. **Ex**: *chore*
      - Choose the scope of the change. **Ex**: *releasing*
      - Add a description. **Ex**: *Add travis config, conventional commit and semantic-release*
      - Add a longer description
      - List break changes or issues closed by this change. **Ex**: *closes #1*
  - See if everything is ok `git log`
    
- **Committing a new feature with commitizen**:
  - Create an issue on GitHub to be closed with that feature/commit
  - Add a new feature and its test
  - `git add`
  - `npm run commit`
  - Type of change: *feat* 
  - Scope: *random*
  - Short description: *Add ability to get an array of starwars names* 
  - Longer description: *If you pass a number to the random function, you will receive an array with that number of random items* 
  - List any break changes/issues closed: *closes #2* 
  - Verify if everything is ok `git log`

- **Automatically running tests before commits with ghooks**:
  - Install **ghooks** `npm i -D ghooks`
  - Configure ghooks in package.json:
    ```json
    "config": {
      "ghooks": {
        "pre-commit": "npm run test:single"
      }
    }
    ```
  - **ps**: *ghooks* will prevent us to commit bad code

- **Adding code coverage recording with Istanbul**:
  - `npm i -D istanbul`
  - Set npm script to run Istanbul:
    ```json
    "scripts": {
      "test:single": "istanbul cover -x *.test.js _mocha -- -R spec src/index.test.js"
    }
    ```
  - Add the `coverage` folder in the `.gitignore` file
  - Run `npm run test:single`

- **Adding code coverage checking**:
  - Check coverage with **ghook**:
    ```json
    "config": {
      "ghooks": {
        "pre-commit": "npm run test:single && npm run check-coverage"
      }
    }
    ```
  - Add check-coverage in npm scripts:
    ```json
    "scripts": {
      "check-coverage": "istanbul check-coverage --statements 100 --branches 100 --functions 100 --lines 100"
    }
    ```
  - Add check-coverage in your CI config file:
    - `.travis.yml`
    ```json
    script:
      - npm run test:single
      - npm run check-coverage
    ```
- **Add code coverage reporting**:
  - Create an account at [codecov.io](https://codecov.io/) 
  - `npm i -D codecov.io`
  - Add **report-coverage** into npm scripts:
    ```json
    "scripts": {
      "report-coverage": "cat ./coverage/lcov.info | codecov"
    }
    ```
  - Add report-coverage in your CI config file:
    - `.travis.yml`
    ```json
    after_success:
      - npm run report-coverage
      - npm run semantic-release
    ```

- **Adding badges to your README**:
  - Go to [shields.io](http://shields.io/) 
  - Choose your badges! :)
  - Markdown structure to add badges: 
    ```
    [![image description](shields.io link)](link the badge to the respective place)
    ```

- **Adding ES6 Support**:
  - `npm i -D babel`
  - Add a **build** task in npm scripts:
    ```json
    "scripts": {
      "build": "babel src/index.js -o dist/index.js"
    }
    ```
  - Change the "main" file in your package.json to `dist/index.js`
  - Add a **prebuild** task into npm scripts:
    ```json
    "scripts": {
      "prebuild": "rm -rf dist && mkdir dist"
    }
    ```
  - Add **build** in your CI config file:
    `.travis.yml`
    ```json
    script:
      - npm run test:single
      - npm run check-coverage
      - npm run build
    ```
  - Add a **postbuild** task in npm scripts:
    ```json
    "scripts": {
      "postbuild": "cp src/starwars-names.json dist/starwars-names.json"
    }
    ```

- **Adding ES6 Support in Tests using Mocha and Babel**:
  - Update your **test** and **test:single** tasks on npm script:
  ```json
  "scripts": {
    "test": "mocha src/index.test.js -w --compilers js:babel/register",
    "test:single": "istanbul cover -x *.test.js _mocha -- -R spec src/index.test.js --compilers js:babel/register"
  }
  ```

- **Limit Built Branches on Travis**:
  - Add the following code in your `.travis.yml`:
    ```
    branches:
      only:
        - master
    ```

**Good luck in your next Open Source JavaScript project**!!!

> If you found something wrong, you can contribute to this article [here](https://github.com/ericdouglas/blog-assets/blob/master/source/_posts/checklist-for-your-new-open-source-javascript-project.md).


