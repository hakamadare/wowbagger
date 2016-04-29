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
            begin
              lb_name = lbd.load_balancer_name

              /^rk-prod-app/ =~ lb_name

              # lb_tags = self.elasticloadbalancing.describe_tags(load_balancer_names: [lb_name]).tag_descriptions[0].tags.collect {|tag| [tag.key, tag.value]}.flatten
              #
              # lb_tags_hash = Hash(*lb_tags)
              #
              # puts lb_tags_hash.inspect
              #
              # exit
              #
              # if all
              #   lb_tags.tag_descriptions.all? {|tag| tags.include?(tag)}
              # else
              #   lb_tags.any? {|tag| tags.include?(tag)}
              # end

            rescue ArgumentError => e
              $stderr.puts "#{lb_name} has no tags"
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

  end
end
