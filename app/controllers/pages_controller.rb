require 'uri'
require 'net/http'
require 'json'

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :connectApi

  def helloWorld
    puts 'hellow hugo'
    addressName = params["addressName"]
    company = params["company"]
    street_address = params["street_address"]
    zip = params["zip"]
    city = params["city"]
    customerId = params["customer_id"]
    customerMail = params["customer_mail"]
    email = params["email"]
    pro_price = params["pro_price"]
    total_price = params["total_price"]
    line_items = JSON.parse(params["line_items"])
    discount_amount1 = total_price.to_i - (pro_price.to_i * 100)
    discount_amount = 0 - discount_amount1

    create_price_rule(discount_amount)
    create_discount(@price_rule_id)
    puts @discount_code.id.class
    puts @discount_code.id
    variant_ids = []
    line_items.each do |item|
      variant_id = item["variant_id"].to_i
      quantity = item["quantity"].to_i
      n = { "quantity" => quantity, "variant_id" => variant_id }
      variant_ids << n
    end

    create_order(variant_ids, customerId)

    render json: {order: @order}
  end

  def create_order(variant_ids, customerId)
    @order = ShopifyAPI::Order.create(line_items: variant_ids, financial_status:"authorized", customer: { id: customerId })
    @order.save
    return @order
  end

  def create_price_rule(discount_amount)
   @price_rule =  ShopifyAPI::PriceRule.create({
                 "price_rule": {
                    "title": "PRO-OFF",
                    "target_type": "line_item",
                    "target_selection": "all",
                    "allocation_method": "across",
                    "value_type": "fixed_amount",
                    "value": -6000,
                    "customer_selection": "all",
                    "starts_at": "2019-10-01T17:59:10Z"
                    }
                  }
                )
   @price_rule_id = @price_rule.id
   return @price_rule_id
  end

  def create_discount(price_rule_id)
    @discount_code = ShopifyAPI::DiscountCode.new
    @discount_code.prefix_options[:price_rule_id] = price_rule_id
    @discount_code.code = "PRO-OFF"
    @discount_code.save
    puts @discount_code.id
  end


  def index
    @products = ShopifyAPI::Product.all
  end

  private

  def connectApi
    shop_url = "https://de69344ecda45841327dbd594af761e5:3623f41fc97008cf4f660757b0fe1acf@calicea.myshopify.com"
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2019-10'
  end

end


