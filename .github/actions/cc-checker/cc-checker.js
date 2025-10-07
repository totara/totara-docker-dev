const { setFailed } = require('@actions/core');
const github = require('@actions/github');
const commitParser = require('conventional-commits-parser');

async function run() {
    const commitTypesEnv = process.env.COMMIT_TYPES;
    if (!commitTypesEnv) {
        setFailed('COMMIT_TYPES not found in environment.');
        return;
    }
    let commitTypeList;
    try {
        commitTypeList = JSON.parse(commitTypesEnv);
    } catch (err) {
        setFailed('Invalid COMMIT_TYPES input. Expecting a JSON array.');
        return;
    }

    const pr = github.context.payload.pull_request;
    if (!pr) {
        setFailed('No pull request found in context.');
        return;
    }

    // Get the GitHub token from env
    const token = process.env.GITHUB_TOKEN;
    if (!token) {
        setFailed('GITHUB_TOKEN not found in environment.');
        return;
    }

    const octokit = github.getOctokit(token);
    const { owner, repo } = github.context.repo;
    const prNumber = pr.number;

    // Fetch all commits in the PR
    const commits = await octokit.rest.pulls.listCommits({
        owner,
        repo,
        pull_number: prNumber,
    });

    let failed = false;
    let errors = [];
    for (const commit of commits.data) {
        const message = commit.commit.message.split('\n')[0].trim();
        const ast = commitParser.sync(message);
        const type = ast.type ? ast.type : '';
        if (!type || !commitTypeList.includes(type)) {
            failed = true;
            errors.push(`Commit ${commit.sha}: Invalid or missing commit type: '${type}'. Must be one of: ${commitTypeList.join(', ')}`);
        }
    }
    if (failed) {
        setFailed(errors.join('\n'));
        return;
    }
    return true;
}

run().catch(err => setFailed(err.message));

module.exports = { run };
