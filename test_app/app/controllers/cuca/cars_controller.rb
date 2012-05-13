module Cuca
  class CarsController < ApplicationController
    def show
      @car = Car.find params[:id]
    end

    def update
      @car = Car.find params[:id]

      respond_to do |format|
        @car.update_attributes params[:cuca_car]
        format.json { respond_with_bip(@car) }
      end
    end
  end
end
