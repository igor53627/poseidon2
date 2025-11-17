# Poseidon2 Workspace Makefile
# Comprehensive build and comparison tools for Poseidon2 implementations

.PHONY: help install build test clean benchmark compare fmt lint snapshot coverage deploy

# Default target
help:
	@echo "Poseidon2 Implementation Comparison Workspace"
	@echo "=============================================="
	@echo ""
	@echo "Setup Commands:"
	@echo "  install          - Install all dependencies"
	@echo "  setup            - Full workspace setup"
	@echo ""
	@echo "Build Commands:"
	@echo "  build            - Build all packages"
	@echo "  build-our        - Build only our implementation"
	@echo "  build-zemse      - Build only zemse implementation"
	@echo "  build-cardinal   - Build only cardinal implementation"
	@echo "  build-tools      - Build only comparison tools"
	@echo ""
	@echo "Test Commands:"
	@echo "  test             - Run all tests"
	@echo "  test-our         - Test only our implementation"
	@echo "  test-zemse       - Test only zemse implementation"
	@echo "  test-cardinal    - Test only cardinal implementation"
	@echo "  test-tools       - Test only comparison tools"
	@echo "  test-gas         - Run gas tests with reporting"
	@echo ""
	@echo "Analysis Commands:"
	@echo "  benchmark        - Run comprehensive benchmarks"
	@echo "  compare          - Run detailed comparison"
	@echo "  analyze          - Generate analysis report"
	@echo "  stress           - Run stress tests"
	@echo ""
	@echo "Utility Commands:"
	@echo "  clean            - Clean all build artifacts"
	@echo "  fmt              - Format all code"
	@echo "  lint             - Run linter"
	@echo "  snapshot         - Generate gas snapshot"
	@echo "  coverage         - Generate coverage report"
	@echo "  flatten          - Flatten contracts"
	@echo ""
	@echo "Deployment Commands:"
	@echo "  deploy-local     - Deploy to local network"
	@echo "  deploy-testnet   - Deploy to testnet"
	@echo "  verify           - Verify contracts"

# Setup Commands
install:
	@echo "Installing dependencies..."
	@npm install
	@cd packages/our-implementation && forge install foundry-rs/forge-std --no-commit
	@cd packages/zemse-poseidon2-evm && forge install foundry-rs/forge-std --no-commit
	@cd packages/cardinal-poseidon2 && forge install foundry-rs/forge-std --no-commit
	@cd packages/comparison-tools && forge install foundry-rs/forge-std --no-commit
	@echo "✅ Dependencies installed"

setup: install build test
	@echo "✅ Workspace setup complete"

# Build Commands
build:
	@echo "Building all packages..."
	@forge build
	@echo "✅ All packages built"

build-our:
	@echo "Building our implementation..."
	@cd packages/our-implementation && forge build
	@echo "✅ Our implementation built"

build-zemse:
	@echo "Building zemse implementation..."
	@cd packages/zemse-poseidon2-evm && forge build
	@echo "✅ Zemse implementation built"

build-cardinal:
	@echo "Building cardinal implementation..."
	@cd packages/cardinal-poseidon2 && forge build
	@echo "✅ Cardinal implementation built"

build-tools:
	@echo "Building comparison tools..."
	@cd packages/comparison-tools && forge build
	@echo "✅ Comparison tools built"

# Test Commands
test:
	@echo "Running all tests..."
	@forge test -vv
	@echo "✅ All tests passed"

test-our:
	@echo "Testing our implementation..."
	@cd packages/our-implementation && forge test -vv
	@echo "✅ Our implementation tests passed"

test-zemse:
	@echo "Testing zemse implementation..."
	@cd packages/zemse-poseidon2-evm && forge test -vv
	@echo "✅ Zemse implementation tests passed"

test-cardinal:
	@echo "Testing cardinal implementation..."
	@cd packages/cardinal-poseidon2 && forge test -vv
	@echo "✅ Cardinal implementation tests passed"

test-tools:
	@echo "Testing comparison tools..."
	@cd packages/comparison-tools && forge test -vv
	@echo "✅ Comparison tools tests passed"

test-gas:
	@echo "Running gas tests with reporting..."
	@forge test --gas-report -vv
	@echo "✅ Gas tests complete"

# Analysis Commands
benchmark:
	@echo "Running comprehensive benchmarks..."
	@forge script packages/comparison-tools/BenchmarkAll.s.sol --rpc-url http://localhost:8545 -vv
	@echo "✅ Benchmarks complete"

compare:
	@echo "Running detailed comparison..."
	@forge script packages/comparison-tools/CompareAll.s.sol --rpc-url http://localhost:8545 -vv
	@echo "✅ Comparison complete"

analyze:
	@echo "Generating analysis report..."
	@forge script packages/comparison-tools/CompareAll.s.sol --rpc-url http://localhost:8545 -vv > analysis-report.md
	@echo "✅ Analysis report generated: analysis-report.md"

stress:
	@echo "Running stress tests..."
	@cd packages/comparison-tools && forge test --match-test "stress" -vv
	@echo "✅ Stress tests complete"

# Utility Commands
clean:
	@echo "Cleaning build artifacts..."
	@forge clean
	@rm -rf packages/*/out packages/*/cache
	@rm -rf out cache
	@echo "✅ Clean complete"

fmt:
	@echo "Formatting code..."
	@forge fmt
	@echo "✅ Code formatted"

lint:
	@echo "Running linter..."
	@solhint 'packages/**/*.sol'
	@echo "✅ Linting complete"

snapshot:
	@echo "Generating gas snapshot..."
	@forge snapshot
	@echo "✅ Gas snapshot generated"

coverage:
	@echo "Generating coverage report..."
	@forge coverage --report lcov
	@echo "✅ Coverage report generated"

flatten:
	@echo "Flattening contracts..."
	@cd packages/our-implementation && forge flatten Poseidon2Main.sol > Poseidon2Main.flattened.sol
	@cd packages/zemse-poseidon2-evm && forge flatten Poseidon2.sol > Poseidon2.flattened.sol
	@cd packages/cardinal-poseidon2 && forge flatten Poseidon2T8.sol > Poseidon2T8.flattened.sol
	@echo "✅ Contracts flattened"

# Deployment Commands
deploy-local:
	@echo "Deploying to local network..."
	@anvil &
	@sleep 2
	@forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
	@echo "✅ Deployed to local network"

deploy-testnet:
	@echo "Deploying to testnet..."
	@forge script script/Deploy.s.sol --rpc-url ${RPC_URL} --broadcast --verify
	@echo "✅ Deployed to testnet"

verify:
	@echo "Verifying contracts..."
	@forge verify-contract ${CONTRACT_ADDRESS} Poseidon2Main --chain ${CHAIN_ID} --etherscan-api-key ${ETHERSCAN_API_KEY}
	@echo "✅ Contracts verified"

# Individual Package Commands (shortcuts)
our: build-our test-our
cardinal: build-cardinal test-cardinal
zemse: build-zemse test-zemse
tools: build-tools test-tools

# Quick comparison
quick-compare:
	@echo "Running quick comparison..."
	@cd packages/comparison-tools && forge script CompareAll.s.sol --rpc-url http://localhost:8545 --sig "run()" | grep -E "(Our Impl|zemse|Cardinal|savings|Savings)"

# Help for specific commands
help-%:
	@echo "Usage: make $*"
	@case '$*' in \
		benchmark) echo "Run comprehensive benchmarks: make benchmark" ;; \
		compare) echo "Run detailed comparison: make compare" ;; \
		deploy) echo "Deploy contracts: make deploy-local or make deploy-testnet" ;; \
		verify) echo "Verify contracts: make verify CONTRACT_ADDRESS=0x... CHAIN_ID=1" ;; \
	esac