# RAProjectTools

Collection of Ruby and Bash scripts that make your life easier.



## What’s Inside


### `sync-resources` / `sync-resources.rb`

The script in `sync-resources.rb` looks at your Xcode project, and finds a group named **Resources**.  If it finds one, and the group itself is associated with a directory in your project — for example, `Project/Resources` — it will attempt to reconcile the contents of the directory with the contents of the group.  Files added to the directory will be added to the Xcode group, and files no longer found will have their references removed.

It works well against projects with *one single target*.  It’s possible to extend the script so it is more robust.  The script uses the [Xcodeproj](git://github.com/CocoaPods/Xcodeproj.git) gem from [CocoaPods](http://cocoapods.org), and the appropriate [Bundler](http://gembundler.com) magic is already set up for you.

Invoke `sync-resources` from the root-level directory containing your project.


### `next-version`

The script in `next-version` bumps the version number by one.  It works with [Git Flow](https://github.com/nvie/gitflow), the awesome branching model for software development, and [AGVTool](http://cocoadev.com/wiki/AGVTool), Apple’s solution for software versioning.

It works pretty well if you are already using these tools.  Remember to start this script from the `develop` branch, and it’ll make a new Git Flow release with the next version number.

Invoke `next-version` from the root-level directory containing your project.
