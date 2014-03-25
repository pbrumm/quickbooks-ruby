module Quickbooks
  module Service
    class Changes < BaseService

      def make_request(options = {})
        entities = options[:entities] || ["Customer", "SalesReceipt", "Account", "Item"]
        time = options[:since] || Time.now - 3600
        response = do_http_get("#{url_for_resource('cdc')}?entities=#{entities.join(',')}&changedSince=#{formatted_date(time)}")
        Quickbooks::Model::ChangesResponse.from_xml(response.plain_body)
      end

      private

        def formatted_date(datetime)
          datetime.strftime('%Y-%m-%dT%H:%M:%S')
        end
    end
  end
end
