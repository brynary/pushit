PushIt -- REST deploy service
=============================

* Runs deploys from a remote, centralized server
* Works with your existing deploy scripts
* Small core, easily extendible with plugins and hooks

Usage
-----

    $ pushit

Plugins
-------

* pushit-webui -- Web interface for deploying
* pushit-capistrano -- Makes your existing Capistrano scripts usable via PushIt
* pushit-campfire -- Deploy directly from Campfire
* pushit-tracker -- Hooks to update Pivotal Tracker stories with deploy information
* pushit-redis -- Record each deploy to Redis
* pushit-growl -- Displays growl notifications before and after deploys
* pushit-saltnpepa -- Plays a fitting music video during deploys

_Note:_ None of the above actually exists yet.