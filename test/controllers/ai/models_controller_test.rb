require "test_helper"

class Ai::ModelsControllerTest < ActionDispatch::IntegrationTest
  test "administrator users can access the models index" do
    sign_in users(:edu)

    get ai_models_url
    assert_response :success
  end

  test "non-administrator users cannot access the models index" do
    sign_in users(:franco)

    get ai_models_url
    assert_response :forbidden
  end

  test "administrator users can access a model" do
    sign_in users(:edu)

    get ai_model_url(ai_models(:ollama_default))
    assert_response :success
  end

  test "non-administrator users cannot access a model" do
    sign_in users(:franco)

    get ai_model_url(ai_models(:ollama_default))
    assert_response :forbidden
  end

  test "administrator users can refresh the models catalog" do
    sign_in users(:edu)

    refreshed = false
    Ai::Model.stub(:refresh!, -> { refreshed = true }) do
      post refresh_ai_models_url
    end

    assert refreshed
    assert_redirected_to ai_models_path
  end

  test "non-administrator users cannot refresh the models catalog" do
    sign_in users(:franco)

    refreshed = false
    Ai::Model.stub(:refresh!, -> { refreshed = true }) do
      post refresh_ai_models_url
    end

    assert_not refreshed
    assert_response :forbidden
  end
end
