package config

// All can be used across multiple commands. Example: unweave ls --all to list all projects
var All = false

// AuthToken is used to authenticate with the Unweave API. It is loaded from the saved
// config file and can be overridden with runtime flags.
var AuthToken = ""

// ProjectPath is the path to the current project to run commands on. It is loaded from the saved
// config file and can be overridden with runtime flags.
var ProjectPath = ""

// SSHKeyPath is the path to the SSH public key to use to connect to a new or existing Session.
var SSHKeyPath = ""

// SSHKeyName is the name of the SSH Key already configured in Unweave to use for a new or existing Session.
var SSHKeyName = ""