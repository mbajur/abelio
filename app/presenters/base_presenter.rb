class BasePresenter
  attr_reader :record

  def initialize(record)
    @record = record
  end

  private

  def local?
    record.local?
  end
end
