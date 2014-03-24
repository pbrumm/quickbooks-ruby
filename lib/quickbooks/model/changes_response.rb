class Quickbooks::Model::ChangesResponse < Quickbooks::Model::BaseModel
  
  class QueryResponse
    include ROXML
    xml_name  "QueryResponse"
    [:Item, :Account, :Invoice, :Customer, :Bill, :SalesReceipt].each do |model|
      xml_accessor model.to_s.underscore.pluralize, from: model.to_s, as: ["Quickbooks::Model::#{model.to_s}".constantize]
    end
  end
  class CdcResponse
    include ROXML
    xml_name  "CDCResponse"

    xml_accessor :responses, :from => :QueryResponse, as: [Quickbooks::Model::ChangesResponse::QueryResponse]
  end

  xml_name  "IntuitResponse"
  xml_accessor :response, :from => :CDCResponse, as: Quickbooks::Model::ChangesResponse::CdcResponse

  def each_change(&block)
    response.responses.each {|query_response|
      [:Item, :Account, :Invoice, :Customer, :Bill, :SalesReceipt].each do |model|
        method = model.to_s.underscore.pluralize.to_sym
        arr = query_response.send(method)
        arr.each {|item|
          block.call item
        } if arr
      end
    }
    return
  end
end
