class ResponseResource < ApplicationRecord
  belongs_to :chunk
  belongs_to :response
end
