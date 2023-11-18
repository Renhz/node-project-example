# node-app-example
with yarn 3 as package manager using pnp feature, this is a node app project example in typescript with dockerfile, ci script, semantic-release and lint set

## Environment

| Environment                   | Description                                                          |
| ----------------------------- | -------------------------------------------------------------------- |
| NODE_ENV                      | production, development                                              |
| DRY_RUN                       | set **true** to avoid any not read operations                        |

## development

1. 準備 node，版本比照 Dockerfile
1. 準備 yarn 3，參考官網以 node 自帶的 corepack 安裝；試著使用 pnp 零安裝，如有遇到所依賴 library 不支援時再切換回來
1. 配置 IDE 參考 [(Yarn)Editor SDKs](https://yarnpkg.com/getting-started/editor-sdks), 透過 .yarn/sdk 讓 IDE 如何找到本專案使用的 typescript, eslint, prettier 模組 (目前僅配置 vscode)
1. (windows) corepace 已知問題：`corepack prepare {pkgmanager}@{version} --activate` 安裝啟用包管理器，下載後路徑改名失敗導致找不到檔案，請參照 https://github.com/nodejs/corepack/issues/246 手動排除

## 專案建置參考流程

- 原始碼控制、包管理器
    1. git
        1. git clone
        - .gitignore 範例
            
            ```bash
            # See https://help.github.com/articles/ignoring-files/ for more about ignoring files.
            
            # dependencies
            node_modules
            
            # testing
            coverage
            .coverage
            
            # production
            build
            dist
            
            # misc
            .DS_Store
            .tmp
            .cache
            
            # https://yarnpkg.com/getting-started/qa#which-files-should-be-gitignored
            # Zero-Installs
            .yarn/*
            !.yarn/cache
            !.yarn/patches
            !.yarn/plugins
            !.yarn/releases
            !.yarn/sdks
            !.yarn/versions
            # not using Zero-Installs:
            .pnp.*
            .yarn/*
            !.yarn/patches
            !.yarn/plugins
            !.yarn/releases
            !.yarn/sdks
            !.yarn/versions
            
            npm-debug.log*
            yarn-debug.log*
            yarn-error.log*
            
            *.local
            *.env*
            !*.example
            .vscode
            docker-compose.yaml
            ```
            
    2. yarn
        1. [使用 yarn 3](https://next.yarnpkg.com/getting-started/install)
            1. nvm use version 選 node 版本 16.17+ 或 18.6+
            2. corepack enable 讓 corepack 來管理包管理器
            3. corepack prepare yarn@stable --activate
                1. windows 需手動處理 corepack prepare 安裝 yarn 改名報錯問題
                    1. https://github.com/nodejs/corepack/issues/246
                    2. corepack 安裝 package manager 到 C:\Users\User\AppData\Local\node\corepack，但因為改名失敗而報錯
            4. yarn set version stable 設置 yarn cli 版本
            5. yarn init -p (--private) 這將會設置 package.json 的 packageManager 欄位
        2. [考量本專案性質及依賴複雜度，決定是否啟用 pnp](https://yarnpkg.com/getting-started/migration)
            1. 不使用 pnp `yarn config set nodeLinker node-modules`
            2. 使用 pnp，除了參照官方文件安裝外
                1. [IDE 還安裝延伸模組、配置 Editor SDKs](https://yarnpkg.com/getting-started/editor-sdks)
                2. yarn dlx @yarnpkg/sdks vscode 會在資料夾增加 .vscode 設定，但如果平常習慣用 vscode 的 workspace 載入多個資料夾，就需手動設定工作區的 typescript.tsdk 指到 .yarn\sdks\typescript\lib
            3. 調整 .gitignore [Questions & Answers | Yarn - Package Manager (yarnpkg.com)](https://yarnpkg.com/getting-started/qa#which-files-should-be-gitignored)
            4. 其他參考資料
                1. [https://blog.csdn.net/weixin_44691608/article/details/122659937](https://blog.csdn.net/weixin_44691608/article/details/122659937)
                2. [Yarn 3.0 Plug'n'Play (PnP) 安装和迁移 - 兴杰 - 博客园 (cnblogs.com)](https://www.cnblogs.com/keatkeat/p/16259314.html)
                3. [yarn 遷移指南](https://yarnpkg.com/getting-started/migration)
- 通用 node 專案
    1. package.json
        1. npm init 輸入必要欄位
        2. 配置 npm script 如
            
            ```json
            "develop": "DEBUG='*,-nodemon*' nodemon src/index.ts",
            "build": "rm -rf dist && tsc -p tsconfig.prod.json",
            "start": "node -r ./tsconfig-paths-bootstrap.js dist/index.js",
            "test": "jest"
            ```
            
            - DEGUG 環境變數值加個引號較安全 https://github.com/debug-js/debug/issues/213
            - windows 因為指令前行內指派環境變數格式不同，導致無法執行 develop 腳本，解法有很多
                - 改在 wsl 裡執行
                - 參考 ‣ 文件新增 npm script developWin: `"@powershell -Command $env:DEBUG='*';node app.js"`****
                - yarn 2+ 幫忙處理了這個問題， windows 也可以直接 yarn develop
    2. yarn add -D 配置開發用套件
        1. typescript 相關套件
            1. @types/node 對應 node 版本
            2. typescript, tsc 編譯工具
            3. nodemen, 需搭配 ts-node 才好直接執行 ts 檔
        2. 測試工具
            1. jest
                - jest 配置（package.json）
                    
                    ```yaml
                    "jest": {
                        "testEnvironment": "node",
                        "preset": "ts-jest",
                        "moduleNameMapper": {
                          "~/(.*)": "<rootDir>/src/$1"
                        },
                        "transform": {
                          "^.+\\.(ts|tsx)$": "ts-jest",
                          "^.+\\.(js)$": "babel-jest"
                        }
                      }
                    ```
                    
                - 對應版本的@types/jest
                - 新版 jest 已支援 typescript，[仍選用 ts-jest 的考量](https://kulshekhar.github.io/ts-jest/docs/babel7-or-ts)
                - 其他: [Jest + TypeScript：建置測試環境 | Titangene Blog](https://titangene.github.io/article/jest-typescript.html)
            2. nock
        3. lint 有關配置
            1. eslint
                1. [配置檔有新格式](https://eslint.org/blog/2022/08/new-config-system-part-2/)
    3. 配置 tsconfig
        1. npx tsc --init 
        2. [建立 TypeScript 專案的起手式 | MagicLen](https://magiclen.org/typescript-start-new-project/)
        3. 或直接沿用其他專案的 tsconfig.json 及有關 npm scripts
        - tsconfig 基本範例
            
            ```json
            {
              "compilerOptions": {
                "target": "es2020",
                "module": "commonjs",
                "baseUrl": "src",
                "paths": {
                  "~/*": ["*"]
                },
                "outDir": "./dist",
                "esModuleInterop": true,
                "forceConsistentCasingInFileNames": true,
                "strict": true,
                "skipLibCheck": true
              },
              "ts-node": {
                "require": ["tsconfig-paths/register"]
              }
            }
            ```
            
            - tsconfig.prod.json 餵給 tsc 打包用
                
                ```json
                {
                  "extends": "./tsconfig",
                  "include": ["src/**/*.ts"],
                  "exclude": ["**/__tests__"]
                }
                ```
                
    4. yarn add 常用套件
        1. tsconfig-paths 處理路徑解析問題
            1. start script 以 node 執行 app 前載入 tsconfig-paths-bootstrap.js 需使用
            2.  [ts-node 也需於 tsconfig.json 配置](https://typestrong.org/ts-node/docs/paths/)
        2. dotenv 方便注入環境變數
        3. cross-fetch 如原碼可能跨環境執行時使用
            
            > The scenario that cross-fetch really shines is when the same JavaScript codebase needs to run on different platforms.
            > 
        4. debug 優化 console 訊息
    5. docker
        1. yarn 如是採[零安裝策略](https://yarnpkg.com/features/zero-installs)，drone、Dockerfile ci 流程需做相應調整
            1. 所依賴 package 已經完全包含在 git clone 下來的 .yarn/cache，如何查找則由 .pnp.cjs 定義
            2. yarn install --immutable --immutable-cache 變成一道檢驗，不會安裝任何東西，省去很多時間
                1. 但是部分包可能快取失敗或鏈結失敗，碰到這情況在 ci 中就不可使用 --immutable-cache 
        2. production package
            1. node 專案 build 階段通常只編譯 src/**/*.ts 到 ./dist，不像前端 spa 專案會把用到的函式庫都包進 bundle
            ⇒ 所以正式映像檔裡仍須存有執行時所需函式庫
            ⇒ 如何只複製必要的 package 到正式映像檔？
                1. 舊版 yarn：yarn install --production 只安裝正式環境所需 dependencies，排除 devdependencies
                2. 新版 yarn：.yarn/cache 正式及開發用套件，需另外使用 [plugin-production-install](https://gitlab.com/Larry1123/yarn-contrib/-/tree/master/packages/plugin-production-install) 另外製作一份 ./yarn/*
                    1. postinstall 如有使用到 devdependencies，例如 husky，視情況選擇以下方案之一
                        1. 如果 production 是作為 library 使用，‣（利用 prepack、postpack）讓使用者 add 本專案時跳過 postinstall
                        2. 在 postinstall npm script 裡寫行內腳本，讓它安靜的失敗，避免導致 ci 流程失敗跳開
                            1. 以前沒有碰到此問題是因為 npm 使用 prepare script，只會在本地安裝時執行
                            2. yarn 2+ 不支援 prepare script，postinstall 無論本地或 --production 都會執行
                    2. `yarn workspaces focus ...`無法排除此問題
                        1. `--all --production`只會異動 .pnp 有關檔案，不會縮小 .yarn/cache 體積
                        2. 可使用 plugin-production-install 來處理體積問題, 詳 https://github.com/debug-js/debug/issues/213
        - .dockerignore 範例
            
            ```bash
            # dependencies
            node_modules
            
            # testing
            **/__tests__
            coverage
            .coverage
            
            # development
            .git
            **/.gitignore
            **/.gitattributes
            *.env*
            !.env.example
            docker-compose*
            *.local
            
            # production
            build
            dist
            
            # misc
            **/*.DS_Store
            .tmp
            .cache
            
            # https://yarnpkg.com/getting-started/qa#which-files-should-be-gitignored
            # Zero-Installs
            .yarn/*
            !.yarn/cache
            !.yarn/patches
            !.yarn/plugins
            !.yarn/releases
            !.yarn/sdks
            !.yarn/versions
            # not using Zero-Installs:
            .pnp.*
            .yarn/*
            !.yarn/patches
            !.yarn/plugins
            !.yarn/releases
            !.yarn/sdks
            !.yarn/versions
            ```
            
        - Dockerfile 範例
            
            ```yaml
            # build stage
            FROM node:18-alpine as builder
            
            LABEL MAINTAINER="renhz"
            
            WORKDIR /var/maxwin/node-app-yarn3-example
            COPY . /var/maxwin/node-app-yarn3-example
            
            RUN apk update
            RUN apk add tzdata git openssh \
              && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
              && apk del tzdata
            
            RUN corepack enable
            RUN yarn install --immutable
            RUN yarn build && echo "Build End"
            RUN yarn prod-install ./build
            RUN cp -r dist ./build
            
            # run stage
            FROM node:18-alpine
            WORKDIR /var/maxwin/node-app-yarn3-example
            COPY ./tsconfig.json ./
            COPY ./tsconfig-paths-bootstrap.js ./
            COPY --from=builder /var/maxwin/node-app-yarn3-example/build .
            
            CMD [ "yarn", "start"]
            ```
            
    6. ci
        1. drone 配置
            - .drone.yml 範例
                
                ```yaml
                kind: pipeline
                type: docker
                name: 
                
                clone:
                  depth: 50
                
                steps:
                  - name: install
                    image: node:18-buster
                    commands:
                      - corepack enable
                      - yarn install --immutable
                    when:
                      branch:
                        - master
                        - develop
                  - name: unit-test
                    image: node:18-buster
                    commands:
                      - yarn test
                    when:
                      branch:
                        - master
                        - develop
                  - name: release
                    image: node:18-buster
                    environment:
                      GIT_AUTHOR_NAME: renhz
                      GIT_AUTHOR_EMAIL: ren.zheng@maxwin.com.tw
                      GIT_COMMITTER_NAME: ${DRONE_COMMIT_AUTHOR_NAME}
                      GIT_COMMITTER_EMAIL: ${DRONE_COMMIT_AUTHOR_EMAIL}
                      GIT_CREDENTIALS:
                        from_secret: bitbucket_username_password
                    commands:
                      - yarn semantic-release
                    when:
                      branch:
                        - master
                      event:
                        - push
                
                  - name: push
                    image: plugins/docker
                    settings:
                      repo: {registryHost:port}/{repoName}
                      registry: {registryHost:port}
                      tags: ${DRONE_TAG}
                      insecure: true
                    when:
                      event:
                        - tag
                ```
                
            - .releaserc.json 範例
                
                ```json
                {
                  "plugins": [
                    "@semantic-release/changelog",
                    "@semantic-release/release-notes-generator",
                    [
                      "@semantic-release/commit-analyzer",
                      {
                        "preset": "angular",
                        "releaseRules": [
                          { "type": "refactor", "release": "patch" },
                          { "type": "style", "release": "patch" },
                          { "type": "test", "release": "patch" },
                          { "type": "ci", "release": "patch" }
                        ]
                      }
                    ],
                    [
                      "@semantic-release/npm",
                      {
                        "npmPublish": false
                      }
                    ],
                    [
                      "@semantic-release/git",
                      {
                        "message": "chore(release): ${nextRelease.version} [ci skip]\n\n${nextRelease.notes}"
                      }
                    ]
                  ],
                  "repositoryUrl": "git@bitbucket.org:maxwin-inc/node-app-yarn3-example.git",
                  "tagFormat": "${version}"
                }
                ```

