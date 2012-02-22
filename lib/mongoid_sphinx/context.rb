class MongoidSphinx::Context
  attr_reader :indexed_models

  def initialize(*models)
    @indexed_models = []
  end

  def prepare
    MongoidSphinx::Configuration.instance.indexed_models.each do |model|
      add_indexed_model model
    end

    return unless indexed_models.empty?

    load_models
  end

  def define_indexes
    indexed_models.each { |model|
      model.constantize.define_indexes
    }
  end

  def add_indexed_model(model)
    model = model.name if model.is_a?(Class)

    indexed_models << model
    indexed_models.uniq!
    indexed_models.sort!
  end

  private

  def load_models
    Object.constants.sort.map(&:constantize).select {|c| c.included_modules.include?(Mongoid::Document) rescue nil }.compact
  end
end
