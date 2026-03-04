# Packaging notes

This module was reorganized from the original shell scripts into a more portable repository layout.

## Main refactoring changes

1. user-specific absolute paths were replaced by a config file
2. single-sample scripts were separated from batch wrapper scripts
3. the sample table header is skipped explicitly in batch execution
4. Picard duplicate metrics and Samtools flagstat outputs were separated into different files
5. bedGraph-to-bigWig conversion was rewritten using the standard `bedGraphToBigWig` command
6. reference files and external resources are now validated through `check_dependencies.sh`
7. a version-collection helper was added for manuscript reporting
8. a demo-subset helper was added for journal reviewer testing
9. SLURM submission now supports dependency chaining from input controls to treatment jobs

## Why this structure is better for GitHub

- configuration is explicit
- scripts are reusable
- documentation is easier to review
- future modules can be added without restructuring the repository
- reviewers can run one sample or the whole table with a clear entry point
