#  How to commit the local code to central O2 repository?

**Last update**: 20261022-1

Here are the steps you need to follow to commit your code from the local O2Physics repository to the centrall O2Physics repository at [https://github.com/AliceO2Group/O2Physics](https://github.com/AliceO2Group/O2Physics).

The main point is that once your code is in the central O2Physics repository, and then shortly afterward in one of the daily release tags, your code can be used to analyze large datasets online in Hyperloop. 

**Disclaimer #1:** Some of the steps below are needed only the very first time you commit your code. 

**Disclaimer #2:** In addition, some steps below can be optimized and further improved using Git built-in functionalities, but I give you now the version which works, see later yourself if you want to optimize it further yourself.  


#### 1. Setting up the GitHub account.
First, in case you already do not have it, you need to create an account on [GitHub](https://github.com) (ideally, by using the same username as you have at CERN, but that is not mandatory). 

After that, login in your GitHub account and authorize "ALICE Continuous Integration" to read your username so that it can be mapped to your CERN account (for more details, see the first two sections in [https://alisw.github.io/git-tutorial/](https://alisw.github.io/git-tutorial/).

On your computer where you are developing the code in the O2Physics repository and where you can run 'git', adapt your credentials and then execute:

```bash
git config --global user.name "<Firstname> <Lastname>" 
git config --global user.email <your-CERN-email-address> 
git config --global user.github <your-GitHub-username>
```


#### 2. Forking.
In this step, you will learn how to clone the central O2Physics repository on GitHub into your own account on GitHub, a process called 'forking'. 

a) Go to the central O2Physics repository on GitHub by following this link [https://github.com/AliceO2Group/O2Physics ](https://github.com/AliceO2Group/O2Physics);

b) Click on the 'Fork' in the top-half-right corner (you can click only if you are already logged in GitHub, if not just click on the top on 'Sign in');

c) If forking went OK, now you shall be automatically redirected to something like [https://github.com/abilandz/O2Physics](https://github.com/abilandz/O2Physics) (adapt the username for your own account, same comments applies wherever below you see 'abilandz').
This is your personal 'fork' for O2Physics repository, of central O2Physics repository at [ https://github.com/AliceO2Group/O2Physics](https://github.com/AliceO2Group/O2Physics).

d) At the time you 'forked' the central repository, your own 'fork' is the 'master' version of [https://github.com/AliceO2Group/O2Physics](https://github.com/AliceO2Group/O2Physics) at the time you did the fork. Few remarks:

* New changes in central 'master' are NOT automatically propagated into your own 'fork' &mdash;  this is summarized in your 'fork' with something like "_This branch is ... ahead and ... behind AliceO2Group/O2Physics:master_"
* The point of having 'fork' is the following: You can propagate changes from your local O2Physics repository directly into the online O2Physics repository, but only in your own 'fork' (certainly NOT in the central O2Physics repository). 
* Only when you want to propagate those changes to the central repository [https://github.com/AliceO2Group/O2Physics](https://github.com/AliceO2Group/O2Physics), a lot of automated checks will be performed, and a person in charge needs to review and approve them 
* In the browser, see if you want to bookmark your own 'fork', as you will be visiting this page frequently.
* If you have screwed-up your 'fork', or if your 'fork' is lagging too much behind the development in https://github.com/AliceO2Group/O2Physics , no worries, you can trivally always delete your 'fork', and make a new 'fork' again (or you can use built-in functionalities in **Git** to synchronize, investigate this further by yourself if interested &mdash; at least in the beginning, keep it simple and just delete your fork and fork it again). To delete a 'fork', just go to your 'fork' online, then click on 'Settings' (last item in the close-to-top horizontal menu), then scroll down to the 'Danger Zone' and opt for 'Delete this repository'. Then, simply go to Step 2a) again. 

To synchronize local 'master' version of O2Physics with the 'forked' master of O2Physics online in GitHub, the typical/standard workflow during code development is the following:

* Make some changes in your analysis task in the local 'master' => propagate those changes to 'forked master' online => propagate online changes from 'forked master' to the 'central master' by creating a pull request (needs several reviews and official approval)
* How to establish the link between 'forked master' in GitHub, with the local 'master' (here I assume that you have checked out already on your desktop 'master' of O2Physics with the standard scripts I gave you &mdash; you do NOT need to recompile this 'master' version from scratch, you can use something like this in the shell function **InstallationO2**:

    ```bash
    InstallationO2_TopLevelBuildDir=someDirectory; InstallationO2_Compile=false; InstallationO2 master
    ```

* Go to the local git repository of your O2Physics 'master' (remember - you do NOT need to compile it from scratch, just check it out locally):

    ```bash
	# use the same path as above:
	cd someDirectory

	# 'abilandz' here is my GitHub account name, replace with yours:
    git remote add abilandz git@github.com:abilandz/O2Physics 

    # In order to cross-check if your local 'master' is now in sync. 
    # with 'forked master' in GitHub, type:
    git remote -v
    ```

	The printout shall be like below (first two lines are your 'fork', and the last two lines are the central repository:
	```bash
	# if you have only the last two lines, the previous step has failed):
    abilandz git@github.com:abilandz/O2Physics (fetch)
    abilandz git@github.com:abilandz/O2Physics (push)
    upstream https://github.com/AliceO2Group/O2Physics (fetch)
    upstream https://github.com/AliceO2Group/O2Physics (push)
	```



#### 3. Setting up a passwordless login for GitHub using SSH.
You need to perform this step if you do not want to type your password again and again when connecting to GitHub from your terminal => basically, you need to follow these online instructions:

* [https://help.github.com/articles/checking-for-existing-ssh-keys/](https://help.github.com/articles/checking-for-existing-ssh-keys/) 
* [https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) 
* [https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)



#### 4. Propagating changes from 'local master' into 'forked master' on GitHub.
If necessary, you can remind yourself about **Git** by having a look at the first two sections of [https://nat3054-ws2627.onrender.com/git.html](https://nat3054-ws2627.onrender.com/git.html).
   
Do some change in your 'local master' where you are regularly developing your code. By default, modify locally ONLY your code, do NOT touch the code of other people!! After you have reviewed and validated your code in your working repository locally, copy only the modified classes into a temporary git repository (named "someDirectory" in step 2b/ above - remember, this one you do NOT compile, you just use it to propagate local changes to your online 'fork'):

Simply do in the terminal:

```bash
cd someDirectory/O2Physics # this is the top O2Physics directory
git status # execute this command to get a summary of all classes which have been changed
git add someCode.cxx # indicate here which code you have modified (in the git vocabulary, you are staging your changes)
git add someOtherCode.cxx # indicate here which code you have modified (in the git vocabulary, you are staging your changes)
git commit -m "some nice commit message" # commit all that you have staged at the previous step. 
git push abilandz # finally, move your changes from 'local master' to 'forked master' on Grid (use your username here)
```

After  this point, changes are on your own 'fork' on GitHub (check now the updated status of your fork on GitHub!), and they are not yet upstream in the central O2Physics repository on GitHub. This means they will not be included in the daily tag, unless you do not perform the next, and the final, step.
          
When for the very first time you are adding a new class to the central O2 repository, you also need to add to your commit the modified specific "CMakeLists.txt file", remember from one of the previous tutorials the lines below...

* copy class student-o2physics.cxx into subdir ~/scratch/aliceO2-1/O2Physics/PWGCF/MultiparticleCorrelations/Tasks

* in that subdir, there is a file "CMakeLists.txt" . Append the following lines end the end of that file:

```cmake
o2physics_add_dpl_workflow(student-o2physics
                    SOURCES student-o2physics.cxx
                    PUBLIC_LINK_LIBRARIES O2::Framework O2Physics::AnalysisCore O2Physics::PWGCFCore
                    COMPONENT_NAME Analysis)
```

By this point, think of a new name for your analysis task, i.e. you can rename "student-o2physics.cxx" into any other name you would prefer, and propagate that change in all other files. In case you have renamed your analysis task "student-o2physics.cxx" into some other file name, use that new name above in "CMakeLists.txt" as well.

#### 5. Propagating changes from 'forked master' on GitHub into 'central master' on GitHub (a.k.a. 'New Pull Request')

* Simply go to your fork of O2Physics on GitHub, click 'Contribute', and then select 'Open Pull Request', and follow the tide.

* After all automated checks in the central repository related to your pull request are successful, and after somebody in charge (the official reviewer) approves your pull request (PR), your code is in the 'master' of the central O2 repository, and it will be included automatically in the next release tag. This procedure can take easily more than 1 day, so you need to be patient. If any of the automated checks failed, you have to fix your code locally immediately, make a new commit, and that commit will be automatically included in the same pull request. 

* The final email you shall receive shall contain the message like this: ```Merged #13241 into master```. This means that your change is now propagated in the 'central master' of O2Physics on GitHub.

* If your change was propagated before 16:00, it will be included in the daily analysis tag, and typically by 20:00 of the same day, it will be deployed all over the Grid (but delays can happen). After this point, you can also use your latest changes on Hyperloop! 

Try to go by yourself ONLY through steps 1-4. Send me the link to your online 'fork' (give me also access permission, if necessary), which has a commit with all the changes you want to propagate to the central repository via pull request, but please DO NOT execute the pull request yet. I will review your changes and provide feedback. 

The very last step 5/ we will do together (only the first time).














