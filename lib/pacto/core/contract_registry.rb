module Pacto
  class ContractRegistry
    def register_contract(contract, *tags)
      tags << :default if tags.empty?

      tags.each do |tag|
        registered[tag] << contract
      end

      self
    end

    def use(tag, values = {})
      merged_contracts = registered[:default] + registered[tag]

      fail ArgumentError, "contract \"#{tag}\" not found" if merged_contracts.empty?

      merged_contracts.each do |contract|
        contract.stub_contract! values
      end

      self
    end

    def registered
      @registered ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def contracts_for(request_signature)
      registered.values.inject(Set.new, :+).select do |contract|
        contract.matches? request_signature
      end
    end

    def contract_for(request_signature)
      contracts_for(request_signature).first
    end
  end
end
