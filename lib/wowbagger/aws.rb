require 'aws-sdk'
require 'ipaddr'

module Wowbagger
  class AWS

    # Route 53 client
    attr_reader :route53

    # EC2 client
    attr_reader :ec2

    # ELB client
    attr_reader :elasticloadbalancing

    # DNS resolver (not actually an AWS client)
    attr_reader :resolv

    def initialize
      begin
        @ec2 = Aws::EC2::Client.new
        @elasticloadbalancing = Aws::ElasticLoadBalancing::Client.new
        @route53 = Aws::Route53::Client.new

        @resolv = Resolv.new

      rescue StandardError => e
        raise e
      end
    end

    def describe_load_balancers_by_tags(tags, all = false)
      begin
        tags = Hash(tags)

        returns = []

        next_marker = 'not_nil'

        lbs = self.elasticloadbalancing.describe_load_balancers

        until next_marker.nil?
          selected = lbs.load_balancer_descriptions.select do |lbd|
            lb_name = lbd.load_balancer_name

            lb_tags = self.elasticloadbalancing.describe_tags(load_balancer_names: [lb_name])

            tag_hashes = lb_tags.tag_descriptions.collect do |td|
              extract_elb_tags_as_hash(td)
            end

            tag_hashes.select do |tag_hash|
              $stderr.puts tag_hash.inspect
              if all
                tag_hash.all? tags
              else
                tag_hash.any? tags.to_a
              end
            end
          end

          returns.concat(selected)

          next_marker = lbs.next_marker
        end

        returns

      rescue StandardError => e
        raise e
      end
    end

    def each_address(hostname, &block)
      begin
        returned = []

        self.resolv.each_address(hostname) do |address|
          returned.push(yield address)
        end

        returned

      rescue StandardError => e
        raise e
      end
    end

    def address_to_elb(address)
      begin
        address = IPAddr.new(address)

        address

      rescue StandardError => e
        raise e
      end
    end

    def extract_elb_tags_as_hash(tag_description)
      begin
        unless tag_description.kind_of?(Aws::ElasticLoadBalancing::Types::TagDescription)
          raise "'#{tag_description.inspect}' is not an Aws::ElasticLoadBalancing::Types::TagDescription" 
        end

        tags = tag_description.tags

        keys = []
        values = []

        tags.each do |tag|
          keys.push(tag.key)
          values.push(tag.value)
        end

        zipped = keys.zip(values).flatten

        Hash[*zipped]

      rescue StandardError => e
        raise e
      end
    end

  end
end
