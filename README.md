# vim-pivo

Note: Right now this is our hack-ish VimL playground. It's not even ready in 1%.

## About

`vim-pivo` is a plugin to Vim text editor which will allow to manage Pivotal Tracker stories right inside of Vim. No more leaving your favorite editor to visit point'n'click land of web browsers just for starting a new task. Also, you will be able to mark one task as what we call _current_ and it will be added to your Git commit message in format: `[#<task_id]` so your manager is kept happy.

## Configuration

Set following variables in your `.vimrc`:

```
let g:PivoProjectId  = "PROJECT_ID" " ability to change projects on the fly... well, maybe soon
let g:PivoApiToken   = "API_KEY"
```

### Contributing

Those are only some hacks gathered during our hackaton. When we fix all the issues and solve all the crimes, we may even increase the version number to 0.1.0 - who knows.

Created by [Jakub Naliwajek](https://github.com/naliwajek), [Michał Poczwardowski](https://github.com/dmp0x7c5). Maintaned by [netguru](https://netguru.co).
