RSpec.describe ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { instance_double('Doorkeeper::AccessToken', acceptable?: true, resource_owner_id: user.id) }

  describe 'POST #import_data' do
    let(:params) { { file:, id: }.compact }
    let(:id) { SecureRandom.uuid }
    let(:file) { nil }

    subject { post(:import_data, params:) }

    context 'when csv file is not provided' do
      let(:expected_errors) do
        {
          errors: [
            { message: 'file: is missing', code: 'CA1001' }
          ]
        }.to_json
      end

      it { expect(subject.body).to eq(expected_errors) }
    end

    context 'when not authorized' do
      let(:file) { fixture_file_upload('sample_dataset.csv') }

      it { should have_http_status(401) }
    end

    context 'when csv does not have required columns' do
      let(:file) { fixture_file_upload('invalid_dataset.csv') }
      let(:expected_errors) do
        { errors: [{ message: 'promotion, outcome, user_id are missing', code: 'CA1001' }] }.to_json
      end

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it { expect(subject.body).to eq(expected_errors) }
    end

    context 'when project does not exist' do
      let(:file) { fixture_file_upload('sample_dataset.csv') }
      let(:expected_errors) do
        { errors: [{ message: "Resource not found: Project #{id}", code: 'CA1002' }] }.to_json
      end

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it { expect(subject.body).to eq(expected_errors) }
    end

    context 'when all params are valid' do
      let(:file) { fixture_file_upload('sample_dataset.csv') }
      let(:project) { create(:project, user_id: user.id) }
      let(:id) { project.id }

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it 'updates project data_imported to true' do
        should have_http_status(200)

        expect(project.reload.data_imported).to be true
      end
    end
  end
end
