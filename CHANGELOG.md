# Changelog
[keepachangelog.com](https://keepachangelog.com/en/0.3.0/)

## 0.3.0 (2022-11-04)

- Added `User-Agent` request header (`blockfrost-crystal/0.3.0 crystal/1.6.0`)
- Added global `default_order` setting for collections 
- Added global `default_count_per_page` setting for collections
- Added CHANGELOG
- Changed query param sanitizer to limit `page` and `count` values within their
  respective ranges
- Added global `retries_in_concurrent_requests` setting
- Added global `sleep_between_retries_ms` setting
- Added method overload with a `pages : Range` argument to fetch multiple pages
  concurrently and return them as one large array
- Changed query param sanitizer to ensure a valid value for the `order` param
- Changed query param sanitizer to include defaults deviating from the API's
  defaults
- Changed the usage of the `order` param in the macros with pagination
- Fixed `"Content-Type"` header in the IPFS upload endpoint
- Changed IPFS endpoint to spawn a new fiber to avoid blocking the main fiber 
  when large files are loaded
- Changed `Blockfrost::Client.sdk_version_string` to be a public class method

## 0.2.1 (2022-10-30)

- Fixed issue with missing `http` lib

## 0.2.0 (2022-10-30)

- Added IPFS endpoints
- Changed shard name from `blockfrost-crystal` to `blockfrost`

## 0.1.0 (2022-10-29)

- First release
