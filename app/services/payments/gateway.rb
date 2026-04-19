module Payments
	class Gateway
		class << self
			attr_accessor :test_gateway
		end

		def self.for(provider)
			return test_gateway if test_gateway

			case provider.to_s
			when "paypal"
				Payments::PaypalGateway.new
			else
				raise ArgumentError, "Unsupported payment provider: #{provider}"
			end
		end
	end
end