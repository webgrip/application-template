## [1.6.1](https://github.com/webgrip/application-template/compare/1.6.0...1.6.1) (2025-09-08)


### Bug Fixes

* Downstream changes that use the new on_source_change ([c7d8632](https://github.com/webgrip/application-template/commit/c7d863286d2bd5d688011bb1eac809a4eaa87927))
* downstream docker changes ([f09f22f](https://github.com/webgrip/application-template/commit/f09f22fa4f46645d0f2d946de13289508ae22b43))
* downstream values ([1e442d2](https://github.com/webgrip/application-template/commit/1e442d2f212438cb8da22e59fdbf053ebe0843bb))
* fixed values.yaml with new downstream correct settings ([8ceff3e](https://github.com/webgrip/application-template/commit/8ceff3ef7656f31dc84ad7337c6c528a7fdf83c2))
* update version in package.json and Chart.yaml ([82c82e9](https://github.com/webgrip/application-template/commit/82c82e94516706f774d0587d35b677480bbf1a5a))

# [1.6.0](https://github.com/webgrip/application-template/compare/1.5.1...1.6.0) (2025-09-03)


### Bug Fixes

* always build docs on change, just don't always deploy to pages. But I still want the artifact ([472daf8](https://github.com/webgrip/application-template/commit/472daf82a9ed0ce6b8cb855439965c29e7be14b7))
* Don't checkout the repo first, might cause trouble ([d5b6671](https://github.com/webgrip/application-template/commit/d5b6671b29242bde0968a8e6108461da4b6c389d))
* final changes ([ccab638](https://github.com/webgrip/application-template/commit/ccab63818df0a85a412015751304cc55c023a46a))
* pulled out ACT and put it where it belongs ([ffba443](https://github.com/webgrip/application-template/commit/ffba443a3c2a9dd62cb86299b4bd88150b6e8820))
* renamed workflow file to follow conventions and final checks for act removal ([00f124f](https://github.com/webgrip/application-template/commit/00f124fab5dd67fa833a8a2fc1526853623b1db3))
* resolve Docker image naming, workflow syntax, and Node.js version consistency issues ([05b4122](https://github.com/webgrip/application-template/commit/05b41229fb37d8d78235941e7cf67a18740aa57a))
* sync on main ([894da15](https://github.com/webgrip/application-template/commit/894da15a3530dd4b72e7b7f54aa99c1f00dcb5d6))
* test ([8314382](https://github.com/webgrip/application-template/commit/8314382bae25a2540cb059efc88cfc9ae4c26b3e))
* use > to make it clearer what we're syncing ([b087a77](https://github.com/webgrip/application-template/commit/b087a77afa5bca718cb6a22fe7bac13331a546a7))
* use ref_name ([ebb1e78](https://github.com/webgrip/application-template/commit/ebb1e784590da31057e8a35cdb145a4f82222ad9))


### Features

* comprehensive application template with automated sync, architectural documentation, and production-ready infrastructure ([0d38f21](https://github.com/webgrip/application-template/commit/0d38f21f48cccfff0d457de66b792d3c48f40a40))
* implement comprehensive ACT testing infrastructure for GitHub workflows ([8501f61](https://github.com/webgrip/application-template/commit/8501f6129d23f7e4743fc6275ea958304bf9f3a9))
* implement Docker-based ACT with locally built image for GitHub Actions testing ([f69acd0](https://github.com/webgrip/application-template/commit/f69acd00f9d6845eb4ee650deaba492e0b89edce))
* implement template file synchronization workflow ([a92691d](https://github.com/webgrip/application-template/commit/a92691df8612de747a84776875301afb5e26b9ba))
* initialize npm project with integrated scripts and Node.js tooling ([5ab7808](https://github.com/webgrip/application-template/commit/5ab7808d223aead53089a87d1ca93bf3080cb9fa))
* update template sync to use 'application' topic and semantic commits ([069980e](https://github.com/webgrip/application-template/commit/069980e1dd2677607c1a33c5754be8b705d754d8))

## [1.5.1](https://github.com/webgrip/application-template/compare/1.5.0...1.5.1) (2025-08-29)


### Bug Fixes

* added laravel app key ([36e0551](https://github.com/webgrip/application-template/commit/36e05517d48a6a856683a6bdb2845b601e9d0793))
* **docker:** fixed something I missed ([dd2153b](https://github.com/webgrip/application-template/commit/dd2153bfe26075bb3ff7efd769d6df9d5a2f809c))

# [1.5.0](https://github.com/webgrip/application-template/compare/1.4.0...1.5.0) (2025-08-28)


### Bug Fixes

* always install node ([b312ccd](https://github.com/webgrip/application-template/commit/b312ccd5070db19b056a896c4ab5e7a990439401))
* check node and npx version ([c795b7d](https://github.com/webgrip/application-template/commit/c795b7d90dada68536be57f88ccab2cbb54025f7))
* comments in .env.example ([bbcf878](https://github.com/webgrip/application-template/commit/bbcf878ace26e27308793507cecd6b4ac9cfe446))
* **docker:** Set up env vars properly ([55dde39](https://github.com/webgrip/application-template/commit/55dde3973ead10897a1582ef61bf6c6fcbdab6f0))
* install make and only run npm stuff in copilot setup steps ([faba336](https://github.com/webgrip/application-template/commit/faba33651dc2efc89bba4148ea21c383b44c2706))
* invoiceninja -> application ([1b3ed0a](https://github.com/webgrip/application-template/commit/1b3ed0a4f21e75d05cb4bf060606b749863e3d29))
* removed npm cache ([fa05730](https://github.com/webgrip/application-template/commit/fa057306e6d8ba5c1bf7ad599e013ab87bd1c520))


### Features

* Got rid of the dockerfile for the application itself, it's important AI does this on its own without something already being there ([aaf4f7d](https://github.com/webgrip/application-template/commit/aaf4f7de71fa451a7c9b8d3311c1424e88eed7d8))

# [1.4.0](https://github.com/webgrip/application-template/compare/1.3.0...1.4.0) (2025-08-28)


### Bug Fixes

* :recycle: Also removed the application docker entrypoint. ([71bbc46](https://github.com/webgrip/application-template/commit/71bbc46b318f4d8bf5655fbc17c2b3dcf5d27a63))
* fixed mariadb ([7117e53](https://github.com/webgrip/application-template/commit/7117e530fbeae93fa8b2d0f33a02ebe3850faaf5))
* typo ([9897eb1](https://github.com/webgrip/application-template/commit/9897eb1d36f7c01dbb3deca3e50584935335d31d))


### Features

* :recycle: remove mkcert and traefik labels for application image, it's causing AI to go haywire and I'm not using it ([8d2746f](https://github.com/webgrip/application-template/commit/8d2746ff6fbd0e326182751c1ef746e0aa4fa468))

# [1.3.0](https://github.com/webgrip/application-template/compare/1.2.2...1.3.0) (2025-08-27)


### Bug Fixes

* added mariadb ([8092175](https://github.com/webgrip/application-template/commit/809217514e8bda52665edd8ecf173e1fc943afe9))
* env and makefile ([ceb2e0c](https://github.com/webgrip/application-template/commit/ceb2e0cf95d75a74b95d60a8cf72efabcffa5d4d))
* webgrip -> organisation, and a typo ([319ce6c](https://github.com/webgrip/application-template/commit/319ce6ce86bf30a4f855d9b08425e67121716621))


### Features

* Added awesome copilot stuff back in ([cd19ea3](https://github.com/webgrip/application-template/commit/cd19ea36cf36c89c41b7482819200978ef116950))

## [1.2.2](https://github.com/webgrip/application-template/compare/1.2.1...1.2.2) (2025-08-26)


### Bug Fixes

* Added copilot-instructions.md ([111234e](https://github.com/webgrip/application-template/commit/111234e8d293c43549473940691647ae843a731c))
* Added env vars to the application docker container, and a healthcheck ([3ed88d8](https://github.com/webgrip/application-template/commit/3ed88d83c8d3d11d7b3d3bfe517aac2d1718f02a))
* added pull_request_template.md ([9fed0b2](https://github.com/webgrip/application-template/commit/9fed0b20c3b59803ac1533f5ede41b777e4a3239))
* added some copilot specific stuff ([cbb9f63](https://github.com/webgrip/application-template/commit/cbb9f63b09980d1a1246c57da277a80c106626f1))
* Added specific copilot instructions for dockerfiles ([48c82a2](https://github.com/webgrip/application-template/commit/48c82a2420361a680f572af1d23f8efe0210bb8e))
* application ([60e35a5](https://github.com/webgrip/application-template/commit/60e35a5334c2421c91c68642122574886f2a3897))
* extra rules for copilot ([d7f2218](https://github.com/webgrip/application-template/commit/d7f221825ae66118cff8cef96a56aed519152bc3))
* slight change in ai files ([d6d3eba](https://github.com/webgrip/application-template/commit/d6d3eba2bffebdb0472269f28724274095a1c8e7))
* stuff ([bf16c63](https://github.com/webgrip/application-template/commit/bf16c63f43798853feb35c3d2d380da346cc8357))
* Touch-up ([f6a5f0f](https://github.com/webgrip/application-template/commit/f6a5f0fb6a1316e3df999fd3c786737b02d4acac))

## [1.2.1](https://github.com/webgrip/application-template/compare/1.2.0...1.2.1) (2025-08-22)


### Bug Fixes

* webgrip -> organisation ([8cbc56d](https://github.com/webgrip/application-template/commit/8cbc56d3d231e136efc4beceb2a4b259b21d4e01))

# [1.2.0](https://github.com/webgrip/application-template/compare/1.1.0...1.2.0) (2025-08-22)


### Bug Fixes

* added redis, fixed readme ([d0a8d20](https://github.com/webgrip/application-template/commit/d0a8d204f279e72075c77080488859819d1d7fb2))
* open port 8080 for the main application by default ([3a9bcc5](https://github.com/webgrip/application-template/commit/3a9bcc5727df22aec28c6c2c1f1c8a565011ec14))
* typo ([b853996](https://github.com/webgrip/application-template/commit/b85399688afbbaf141009f16625cdf2513252a10))


### Features

* added CODEOWNERS file ([e288ad6](https://github.com/webgrip/application-template/commit/e288ad6b7fd93fb80bcbea7217d9321d8fa3f74a))
* fast forward development to main ([523f11b](https://github.com/webgrip/application-template/commit/523f11b1f7c3d85de16793c69ac56e7b1cd7f113))

# [1.1.0](https://github.com/webgrip/application-template/compare/1.0.0...1.1.0) (2025-08-19)


### Bug Fixes

* fixed depends_on ([ae6b064](https://github.com/webgrip/application-template/commit/ae6b064df86f1d5b415cf9207fe032a1b1c54257))


### Features

* added bjw-s-labs app-template and fixed deployment stuff ([1c23e97](https://github.com/webgrip/application-template/commit/1c23e97074d681e6c932fcce31d4b404a0faee7e))

# 1.0.0 (2025-08-18)


### Bug Fixes

* moved away from bitnami because they're greedy fucks ([1d3e767](https://github.com/webgrip/application-template/commit/1d3e767b13c0ddd15925239313fa8cff98363aab))
