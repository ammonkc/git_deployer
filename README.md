# git deployer script v0.8.0

Ammon Casey @ammonkc


## Quick start

* Put `*.hook.template` files into `.git_tpl/` folder
* Put `create_repo.sh` into `/usr/local/bin`
* Make the script executable: `chmod +x`

## Usage

* `create_repo <domain.com>`
* It will ask for these options:
    - Environment
    - Framework
    - Web root folder name
