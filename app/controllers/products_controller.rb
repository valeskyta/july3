class ProductsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:confirmation, :failure, :success]
  before_action :set_product, only: [:show, :edit, :update, :destroy]


  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  def pay
    @product = Product.find(params[:id])
    @payment = Payment.create

    @payment.oreder_id = @payment.id.to_s + SecureRandom.random_number(10).to_s
    @payment.session_id = SecureRandom.random_number(10)
    @payment.amount = @product.precio
    @payment.status = false
    @payment.product = @product
    @payment.save

    @tbk_url_cgi = "http://186.64.122.15/cgi-bin/valeskyta/tbk_bp_pago.cgi"
    @tbk_tipo_transaccion = "TR_NORMAL"
    @tbk_url_exito = "http://valeska.beerly.cl/products/success"
    @tbk_url_fracaso = "http://valeska.beerly.cl/products/failure"


  end

  def confirmation
    payment = Payment.where(oreder_id: params[:TBK_ORDEN_COMPRA]).where(session_id: params[:TBK_ID_SESION]).first
    rejected = false
    rejected = true if payment.nil?
    rejected = true if payment.amount.to_s + "00" != params[:TBK_MONTO]
    rejected = true if !params.has_key?(:TBK_RESPUESTA) || !params.has_key?(:TBK_ORDEN_COMPRA) || !params.has_key?(:TBK_TIPO_TRANSACCION) || !params.has_key?(:TBK_MONTO) || !params.has_key?(:TBK_CODIGO_AUTORIZACION) || !params.has_key?(:TBK_FECHA_CONTABLE) || !params.has_key?(:TBK_HORA_TRANSACCION) || !params.has_key?(:TBK_ID_SESION) || !params.has_key?(:TBK_ID_TRANSACCION) || !params.has_key?(:TBK_TIPO_PAGO) || !params.has_key?(:TBK_NUMERO_CUOTAS) || !params.has_key?(:TBK_VCI) || !params.has_key?(:TBK_MAC)
    rejected = true if payment.status

    payment.status = true
    payment.payment_type = params[:TBK_TIPO_PAGO]
    if rejected
      render text: "RECHAZADO"
    else
      if params[:TBK_RESPUESTA] == "0"
        #Aca hay lucas :)
        payment.card_last_numbers = params[:TBK_FINAL_NUMERO_TARJETA]
        payment.authorization = params[:TBK_CODIGO_AUTORIZACION]
      end
      render text: "ACEPTADO"
    end
    payment.save
  end

  def success
    @payment = Payment.where(oreder_id: params[:TBK_ORDEN_COMPRA]).where(session_id: params[:TBK_ID_SESION]).first

  end

  def failure

  end


  # def confirmation
  #   logger.info "hola me estoy llamando"
  #   render text: "ACEPTADO"
  # end
  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:description, :precio, :cantidad)
    end
end
