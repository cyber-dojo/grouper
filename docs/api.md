
# API
- - - -
## POST assert(command)
Runs a single [command](#command).  
Returns  [(JSON-out)](#json-out) its result when it succeeds.  
Raises `ServiceError` when it fails.
- example
  ```bash
  $ dirname=/cyber-dojo/katas/12/34/56
  $ curl \
    --data '{"command":["dir_make","${dirname}"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert

  {"assert":true}
  ```

- - - -
## POST run(command)
Runs a single [command](#command).  
Returns  [(JSON-out)](#json-out) its result.
- example
  ```bash
  $ dirname=/cyber-dojo/katas/34/E3/R6
  $ curl \
    --data '{"command":["dir_make","${dirname}"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run

  {"run":true}
  ```

- - - -
## POST assert_all(commands)
Runs all [commands](#commands).  
When they all succeed, returns their results in an array.  
When one of them fails, immediately raises `ServiceError`.  
- example
  ```bash
  $ dirname=/cyber-dojo/groups/45/Pe/6N
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_exists?","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert_all

  {"assert_all":[true,true]}
  ```

- - - -
## POST run_all(commands)
Runs all [commands](#commands).  
Returns their results in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/2P/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_all

  {"run_all":[true,false]}
  ```

- - - -
## POST run_until_true(commands)
Runs [commands](#commands) until one is true.  
Returns their results (including the last true one) in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/12/5Q/6E
  $ curl \
    --data '{"commands":[["dir_exists?","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_true

  {"run_until_true":[false,true]}
  ```

- - - -
## POST run_until_false(commands)
Runs [commands](#commands) until one is false.  
Returns their results (including the last false one) in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/1q/K4/d9
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_false

  {"run_until_true":[true,false]}
  ```

- - - -
## commands
An array of [command]s(#commands)s


## command
There are 5 commands.  
They _always_ raise when there is no space left of the file-system device.  
They raise instead of returning false, when in an `assert` or `assert_all` command.
* [dir_make_command](#dir_make_command)
* [dir_exists_command](#dir_exists_command)
* [file_create_command](#file_create_command)
* [file_append_command](#file_append_command)
* [file_read_command](#file_read_command)

- - - -
# dir_make_command
A command to create a dir.  
An array of two elements `["dir_make","${DIRNAME}"]`  
Corresponds to the bash command `mkdir -p ${DIRNAME}`.
- example
  ```json
  [ "dir_make", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- returns
  * **true** when the `dir_make` succeeds.
  * **false** when the `dir_make` fails.
    - Can fail because **DIRNAME** already exists as a dir.
    - Can fail because **DIRNAME** already exists as a file.

- - - -
# dir_exists_command
A query to determine if a dir exists.  
An array of two elements `["dir_exists?","${DIRNAME}"]`  
Corresponds to the bash command `[ -d ${DIRNAME} ]`.    
- example
  ```json
  [ "dir_exists?", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- returns
  * **true** when **DIRNAME** exists.
  * **false** when **DIRNAME** does not exist.

- - - -
# file_create_command
A command to create a _new_ file.  
An array of three elements `["file_create", "${FILENAME}","${CONTENT}"]`  
Creates a _new_ file called **FILENAME** with content **CONTENT** in an _existing_ dir (created with a `dir_make_command`).
- example
  ```json
  [ "file_create", "/cyber-dojo/katas/4R/5S/w4/manifest.json", "{...}" ]
  ```
- returns
  * **true** when the file creation succeeds.
  * **false** when the file creation fails.
    - Can fail because **FILENAME** already exists.
    - Can fail because **FILENAME** exists as a dir.

- - - -
# file_append_command
A command to append to an _existing_ file.  
An array of three elements `["file_create", "${FILENAME}","${CONTENT}"]`  
Appends **CONTENT** to an _existing_ file called **FILENAME** (created with a `file_create_command`)
- example
  ```json
  [ "file_append", "/cyber-dojo/katas/RS/y3/1B/manifest.json", "{...}" ]  
  ```
- returns
  * **true** when the file append succeeds.
  * **false** when the file append fails.
    - Can fail because **FILENAME** does not exist.
    - Can fail because **FILENAME** exists as a dir.

- - - -
# file_read_command
A command to read from an _existing_ file.  
An array of two elements `["file_read","${FILENAME}"]`  
Reads the contents of an _existing_ file called **FILENAME**.
- example
  ```json
  [ "file_read", "/cyber-dojo/katas/N2/u8/9W/events.json" ]
  ```
- returns
  * **content** when the file read succeeds.
  * **false** when the file read fails.
    - Can fail because **FILENAME** does not exist.
    - Can fail because **FILENAME** exists as a dir.

- - - -
## GET ready?
Tests if the service is ready to handle requests.  
Used as a [Kubernetes](https://kubernetes.io/) readiness probe.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true** when the service is ready
  * **false** when the service is not ready
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

  {"ready?":false}
  ```

- - - -
## GET alive?
Tests if the service is alive.  
Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true**
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/alive?

  {"alive?":true}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha

  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
  ```


- - - -
## JSON in
- All methods pass any arguments as a json hash in the http request body.
  * If there are no arguments you can use `''` (which is the default
    for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
  * If the method completes, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

    {"ready?":true}
    ```
  * If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --silent -X POST http://${IP_ADDRESS}:${PORT}/assert_all | jq      

    {
      "exception": {
        "path": "/assert_all",
        "body": "",
        "class": "SaverService",
        "message": "...",
        "backtrace": [
          ...
          "/usr/bin/rackup:23:in `<main>'"
        ]
      }
    }
    ```