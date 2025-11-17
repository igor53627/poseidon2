# Pull Request

## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Security enhancement

## Packages Affected
<!-- Check which packages are modified in this PR -->
- [ ] `packages/our-implementation/` - ⚠️ **Requires Review**
- [ ] `packages/cardinal-poseidon2/` - ✅ **Excluded from Review** (benchmarking only)
- [ ] `packages/comparison-tools/` - ✅ **Excluded from Review** (benchmarking only)  
- [ ] `packages/zemse-poseidon2-evm/` - ✅ **Excluded from Review** (benchmarking only)

## Security Checklist (for non-excluded packages)
If changes affect `packages/our-implementation/`:
- [ ] I have run `slither` and addressed any findings
- [ ] I have added appropriate tests
- [ ] I have updated documentation
- [ ] I have considered gas optimization
- [ ] I have validated input handling

## Review Notes
### For Reviewers:
- **Changes to excluded packages** (`cardinal-poseidon2`, `comparison-tools`, `zemse-poseidon2-evm`) are for benchmarking/comparison purposes only and do not require detailed security review
- **Changes to `our-implementation`** require full security review per our security standards
- **Auto-labeling** will apply `excluded-packages` label to PRs that only touch benchmarking packages

## Testing
- [ ] Unit tests pass
- [ ] Fuzz tests pass
- [ ] Gas benchmarks completed (if applicable)
- [ ] Security analysis completed (if applicable)

## Additional Notes
<!-- Any additional context, concerns, or notes for reviewers -->