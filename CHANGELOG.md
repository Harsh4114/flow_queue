# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

---
## [1.2.0] Stable 

### Improved

* README documentation 
* Change log formatting


## [1.1.0] 

### Added

* Persistent SQLite-based queue system
* Priority-based task execution
* FIFO processing inside same priority
* Retry support with new process creation
* Queue state management
* Stream-based task updates
* Multiple queue support
* UUID-based process IDs
* Background task execution workflow
* Queue listener support
* Task history architecture using parent process ID
* README documentation with examples
* Queue priority scheduling system

### Improved

* Developer-friendly API design
* Queue processing architecture
* SQLite schema structure
* Internal task lifecycle management
* Package discoverability using pub.dev topics

### Technical

* Added `sqflite`
* Added `uuid`
* Added SQLite task persistence
* Added queue worker engine
* Added queue stream controller
* Added retry queue architecture

### Notes

* Phase 1 stores task callbacks in memory
* App restart recovery is planned for future releases
* Isolate execution planned for Phase 2

`
---
## [1.0.0] 
- Initial stable release.
- Public API: `FlowQueue`, `QueueTask`, priority and state enums.
- SQLite-backed persistence and task execution support.
