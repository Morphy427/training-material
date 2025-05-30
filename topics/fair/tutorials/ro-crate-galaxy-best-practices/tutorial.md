---
layout: tutorial_hands_on
title: "Best practices for workflows in GitHub repositories"
time_estimation: "30M"
questions:
- What are Workflow Best Practices
- How does RO-Crate help?
objectives:
- Generate a workflow test using Planemo
- Understand how testing can be automated with GitHub Actions
key_points:
- repo2rocrate lets you easily generate templated out metadata for your workflow
- Generating tests is easy and something everyone should do.
tags:
- ro-crate
priority: 3
contributions:
  authorship:
    - simleo
    - elichad
  funding:
    - by-covid
    - eurosciencegateway
license: Apache-2.0
subtopic: ro-crate
notebook:
  language: bash
---

A workflow, just like any other piece of software, can be formally correct and runnable but still lack a number of additional features that might help its reusability, interoperability, understandability, etc.

One of the most useful additions to a workflow is a suite of tests, which help check that the workflow is operating as intended. A test case consists of a set of inputs and corresponding expected outputs, together with a procedure for comparing the workflow's actual outputs with the expected ones. It might be the case, in fact, that a test may be considered successful even if the actual outputs do not match the expected ones exactly, for instance because the computation involves a certain degree of randomness, or the output includes timestamps or randomly generated identifiers.

Providing documentation is also important to help understand the workflow's purpose and mode of operation, its requirements, the effect of its parameters, etc. Even a single, well structured README file can go a long way towards getting users started with your workflow, especially if complemented by examples that include sample inputs and running instructions.

> <agenda-title></agenda-title>
>
> In this tutorial, you will learn about the best practices that the Galaxy community 
> has created for workflows.
>
> 1. TOC
> {:toc}
>
{: .agenda}

> <tip-title>Using your own workflow</tip-title>
>
> This tutorial assumes that you already have a Galaxy workflow that you want to apply best practices to. You can follow along using any workflow you have created or imported during a previous tutorial (such as [A short introduction to Galaxy]({% link topics/introduction/tutorials/galaxy-intro-short/workflows/index.md %})).
>
{: .tip}

## Community best practices

Though the practices listed in the introduction can be considered general enough to be applicable to any kind of software, individual communities usually add their own specific sets of rules and conventions that help users quickly find their way around software projects, understand them more easily and reuse them more effectively. The Galaxy community, for instance, has a [guide on best practices for maintaining workflows](https://planemo.readthedocs.io/en/latest/best_practices_workflows.html) and a built-in Best Practices panel in the workflow editor (see the tip below).

{% snippet faqs/galaxy/workflows_best_practices.md %}

> <hands-on-title>Apply best practices for workflow structure</hands-on-title>
>
> 1. Open your workflow for editing and find the **Best Practices** panel (see the tip above).
> 1. Resolve the warnings that appear until every item has a green tick.
>
{: .hands_on}

The [Intergalactic Workflow Commission (IWC)](https://github.com/galaxyproject/iwc) is a collection of highly curated Galaxy workflows that follow best practices and conform to a specific GitHub directory layout, as specified in the [guide on adding workflows](https://github.com/galaxyproject/iwc/blob/main/workflows/README.md#adding-workflows). In particular, the workflow file must be accompanied by a [Planemo test file](https://planemo.readthedocs.io/en/latest/test_format.html) with the same name but a `-test.yml` extension, and a `test-data` directory that contains the datasets used by the tests described in the test file. The guide also specifies how to fulfill other requirements such as setting a license, a creator and a version tag. A new workflow can be proposed for inclusion in the collection by opening a pull request to the [IWC repository](https://github.com/galaxyproject/iwc): if it passes the review and is merged, it will be published to [iwc-workflows](https://github.com/iwc-workflows). The publication process also generates a metadata file that turns the repository into a [Workflow Testing RO-Crate](https://crs4.github.io/life_monitor/workflow_testing_ro_crate), which can be registered to [WorkflowHub](https://workflowhub.eu/) and [LifeMonitor](https://www.lifemonitor.eu/).


## Best practice repositories and RO-Crate

The [repo2rocrate](https://github.com/crs4/repo2rocrate) software package allows to generate a [Workflow Testing RO-Crate](https://crs4.github.io/life_monitor/workflow_testing_ro_crate) for a workflow repository that follows community best practices. It currently supports Galaxy (based on IWC guidelines), Nextflow and Snakemake. The tool assumes that the workflow repository is structured according to the community guidelines and generates the appropriate [RO-Crate](https://w3id.org/ro/crate/) metadata for the various entities. Several command line options allow to specify additional information that cannot be automatically detected or needs to be overridden.

To try the software, we'll clone one of the iwc-workflows repositories, whose layout is known to respect the IWC guidelines. Since it already contains an RO-Crate metadata file, we'll delete it before running the tool.

```bash
pip install repo2rocrate
git clone https://github.com/iwc-workflows/parallel-accession-download
cd parallel-accession-download/
rm -fv ro-crate-metadata.json
repo2rocrate --repo-url https://github.com/iwc-workflows/parallel-accession-download
```

This adds an `ro-crate-metadata.json` file at the top level with metadata generated based on the tool's knowledge of the expected repository layout. By specifying a zip file as an output with the `-o` option, we can directly generate an RO-Crate in the format accepted by WorkflowHub and LifeMonitor:

```bash
repo2rocrate --repo-url https://github.com/iwc-workflows/parallel-accession-download -o ../parallel-accession-download.crate.zip
```


## Generating tests for your workflow

What if you only have a workflow, but you don't have the test layout yet? You can use Planemo to generate it.

```bash
pip install planemo
```

As an example we will use this [simple workflow](https://github.com/crs4/life_monitor/blob/50cdb790ff125613aa07e70cb439e3a36b82d0bf/interaction_experiments/workflow_examples/galaxy/sort-and-change-case/sort-and-change-case.ga), which has only two steps: it sorts the input lines and changes them to upper case. Follow these steps to generate a test layout for it:


> <hands-on-title>Generate Workflow Tests With Planemo</hands-on-title>
> 1. Download [the workflow](https://raw.githubusercontent.com/crs4/life_monitor/50cdb790ff125613aa07e70cb439e3a36b82d0bf/interaction_experiments/workflow_examples/galaxy/sort-and-change-case/sort-and-change-case.ga) to a `sort-and-change-case.ga` file.
> 1. Download [this input dataset](https://raw.githubusercontent.com/crs4/life_monitor/50cdb790ff125613aa07e70cb439e3a36b82d0bf/interaction_experiments/workflow_examples/galaxy/sort-and-change-case/input.bed) to an `input.bed` file.
> 1. Upload the workflow to Galaxy (e.g., [Galaxy Europe](https://usegalaxy.eu/)): from the upper menu, click on "Workflow" > "Import" > "Browse", choose `sort-and-change-case.ga` and then click "Import workflow".
> 1. Rename the uploaded workflow from `sort-and-change-case (imported from uploaded file)` to `sort-and-change-case` by clicking the pencil icon next to the workflow name. 
> 1. Start a new history: click on the "+" button on the History panel to the right.
> 1. Upload the input dataset to the new history: on the left panel, go to "Upload Data" > "Choose local files" and select `input.bed`, then click "Start" > "Close".
> 1. Wait for the file to finish uploading (i.e., for the loading circle on the dataset's line in the history to disappear).
> 1. Run the workflow on the input dataset: click on "Workflow" in the upper menu, locate `sort-and-change-case`, and click on the play button to the right.
> 
>   ![Workflow Entry](img/workflow-entry.png)
> 
> 1. This should take you to the workflow running page. The input slot should be already filled with `input.bed` since there is nothing else in the history. Click on "Run Workflow" on the upper right of the center panel.
> 
>    ![Workflow Run Page](img/workflow-run-page.png)
> 
> 1. Wait for the workflow execution to finish.
> 1. On the upper menu, go to "Data" > "Workflow Invocations", expand the invocation corresponding to the workflow just run and copy the invocation's ID. In my case it says "Invocation ID: 86ecc02a9dd77649" on the right, where `86ecc02a9dd77649` is the ID.
>  
>    ![Workflow Invocation](img/workflow-invocation.png)
> 
> 1. On the upper menu, go to "User" > "Preferences" > "Manage API Key". If you don't have an API key yet, click the button to create a new one. Under "Current API key", click the button to copy the API Key on the right.
> 
>    ![API key](img/api-key.png)
> 
> 1. Run `planemo workflow_test_init --galaxy_url https://usegalaxy.eu --from_invocation INVOCATION_ID --galaxy_user_key API_KEY`, replacing `INVOCATION_ID` with the actual invocation ID and `API_KEY` with the actual API key. If you're not using the Galaxy Europe instance, also replace `https://usegalaxy.eu` with the URL of the instance you're using.
> 1. Browse the files that have been created - `sort-and-change-case-tests.yml` and `test_data/`
>
> Optionally see this tip for more details:
>
> {% snippet faqs/gtn/gtn_workflow_testing.md %}
>
{: .hands_on}

> <question-title></question-title>
>
> 1. How do the files in `test_data/` relate to your Galaxy history?
> 2. Look at the contents of `sort-and-change-case-tests.yml`. What are the expected outputs of the test?
>
> > <solution-title></solution-title>
> >
> > 1. The files in `test_data/` correspond to the output files in the history, though some of the names are different:
> >   1. `bed_input.bed` has the same name in the history - this is the input file we uploaded
> >   2. `sorted_bed.bed` corresponds to the `Sort on data 1` step (you can confirm this by viewing the file contents)
> >   2. `uppercase_bed.tabular` corresponds to the `Change case on data 2` step (you can confirm this by viewing the file contents)
> > 2. The expected outputs are `test-data/sorted_bed.bed` and `test-data/uppercase_bed.tabular`. This means that when the workflow is run on the input (`test-data/bed_input.bed`), it is expected to produce two files that look exactly like those outputs.
> >
> {: .solution}
{: .question}

To build up the test suite further, you can invoke the workflow multiple times with different inputs, and use each invocation to generate a test, using the same command as before:

```bash
planemo workflow_test_init --galaxy_url https://usegalaxy.eu --from_invocation INVOCATION_ID --galaxy_user_key API_KEY
```

Each invocation should test a different behavior of the workflow. This could mean using different datatypes for inputs, or changing the workflow settings to produce different results.

> <hands-on-title>Generate tests for your own workflow</hands-on-title>
> 1. Create a new folder on your computer to store the workflow.
> 1. Download the Galaxy workflow you updated to follow best practices earlier in this tutorial. You can do this by going to the Workflow page and clicking {% icon galaxy-download %} **Download workflow in .ga format**.
> 1. Create a new Galaxy history, and run the workflow on some appropriate input data.
> 1. Use `planemo` to turn that workflow invocation into a test case.
{: .hands_on}


## Adding a GitHub workflow for running tests automatically

In the previous section, you learned how to generate a test layout for an example Galaxy workflow. This procedure also gives you the file structure you need to populate the GitHub repository in line with community best practices. One thing is still missing though: a GitHub workflow to test the Galaxy workflow automatically. Let's create this now.

At the top level of the repository, create a `.github/workflows` directory and place a `wftest.yml` file inside it with the following content:

```yaml
name: Periodic workflow test
on:
  schedule:
    - cron: '0 3 * * *'
  workflow_dispatch:
jobs:
  test:
    name: Test workflow
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
      with:
        fetch-depth: 1
    - uses: actions/setup-python@v1
      with:
        python-version: '3.7'
    - name: install Planemo
      run: |
        pip install --upgrade pip
        pip install planemo
    - name: run planemo test
      run: |
        planemo test --biocontainers sort-and-change-case.ga
```

Replacing `sort-and-change-case.ga` with the name of your actual Galaxy workflow. You can find extensive [documentation on GitHub workflows](https://docs.github.com/en/actions/using-workflows) on the GitHub web site. Here we'll give some highlights:

 * the `on` field sets the GitHub workflow to run:
   * automatically every day at 3 AM
   * when manually dispatched
 * the steps do the following:
   * check out the GitHub repository
   * set up a Python environment
   * install Planemo
   * run `planemo test` on the Galaxy workflow

An example of a repository built according to the guidelines given here is [simleo/ccs-bam-to-fastq-qc-crate](https://github.com/simleo/ccs-bam-to-fastq-qc-crate), which realizes the Workflow Testing RO-Crate setup for [BAM-to-FASTQ-QC](https://workflowhub.eu/workflows/220).

Your workflow is now ready to add to GitHub! If you're not familiar with GitHub, follow these instructions to create a repository and upload your workflow files: [Uploading a project to GitHub](https://docs.github.com/en/get-started/start-your-journey/uploading-a-project-to-github).
