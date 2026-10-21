# O2 coding style and rules, O2linter, etc.
**Last update**: 20261021-1

In this part of the O2 tutorial, O2 coding style and rules are covered, and usage of related software (e.g. O2linter) is introduced. From the very beginning, you need to conform to the official O2 coding style and rules, otherwise, you won't be able to contribute the code to the central O2 repository. 

#### 1. Common code formatting.
For common code formatting, use locally:

```bash
$ clang-format -i someFile
```

If you do not already have it installed, the command ```clang-format``` is available after you initialize the O2 environment. The flag ```-i``` will modify your file in-place (i.e. it will reformat the file and then overwrite the original file) &mdash; this is potentially dangerous, therefore see if you want to develop a shell script, which will first make a backup of "someFile", before in that script you call ```clang-format``` for that file.


#### 2. Running O2linter locally.
When you eventually create a pull request for your code to be included into the official O2 repository [https://github.com/AliceO2Group/O2Physics](https://github.com/AliceO2Group/O2Physics), so that you can use your code in the Hyperloop in online analysis, it will go first through ~10 automated checks, before your pull request will be approved. One automated test that will be added in the near future as mandatory is O2linter (still under development!), you can find a summary of its current status in Vít Kučera slides (i uploaded them in the following same public online [directory](https://cernbox.cern.ch/s/akoLJYlc8Ovk4aZ)). Do NOT get lost in the details, the most important slides are 11, 12, 18, and particularly 24.

To run O2linter locally, simply use:

```bash
# adapt the path below to your working git repository
# in which you compile and run the code:
$ cd ~/scratch/aliceO2-12/O2Physics
$ python3 Scripts/o2_linter.py PWGCF/MultiparticleCorrelations/Tasks/<your-task>
```

From the very beginning, try to implement locally all O2linter suggestions, etc.


#### 3. O2 coding guidelines.
Check also [https://github.com/AliceO2Group/CodingGuidelines](https://github.com/AliceO2Group/CodingGuidelines) and references therein.
