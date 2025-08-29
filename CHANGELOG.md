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
