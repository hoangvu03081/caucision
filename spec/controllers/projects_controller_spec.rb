RSpec.describe ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { instance_double('Doorkeeper::AccessToken', acceptable?: true, resource_owner_id: user.id) }

  describe 'POST #import_data' do
    let(:params) { { file:, id:, control_promotion: }.compact }
    let(:id) { SecureRandom.uuid }
    let(:file) { nil }
    let(:control_promotion) { 'No e-mail' }

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
      let(:expected_response) do
        {
          data_imported: true,
          model_trained: false,
          control_promotion: 'No e-mail',
          graph_imported: false,
          data_schema: {
            user_id: { type: 'int', unique_values: 64000 },
            recency: { type: 'int', unique_values: 12 },
            history_segment: { type: 'text', unique_values: 7 },
            history: { type: 'float', unique_values: 34833 },
            mens: { type: 'int', unique_values: 2 },
            womens: { type: 'int', unique_values: 2 },
            zip_code: { type: 'text', unique_values: 3 },
            newbie: { type: 'int', unique_values: 2 },
            channel: { type: 'text', unique_values: 3 },
            promotion: { type: 'text', unique_values: 3 },
            outcome: { type: 'int', unique_values: 6 }
          }
        }
      end

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it 'updates project data_imported to true' do
        should have_http_status(200)

        expect(
          JSON.parse(subject.body, symbolize_names: true)
        ).to match(a_hash_including(expected_response))

        expect(project.reload.data_imported).to be true
      end
    end
  end

  describe 'POST #import_causal_graph' do
    let(:params) { { id:, causal_graph: }.compact }
    let(:id) { SecureRandom.uuid }
    let(:causal_graph) do
      {
        'outcome' => [],
        'segment' => ['outcome'],
        'history_segment' => ['outcome'],
        'newbie' => ['outcome'],
        'recency' => ['outcome'],
        'history' => ['outcome'],
        'womens' => ['outcome'],
        'mens' => ['outcome'],
        'channel' => ['outcome'],
        'zip_code' => ['outcome'],
        'promotion' => ['outcome']
      }
    end

    subject { post(:import_causal_graph, params:) }

    context 'when csv file is not provided' do
      let(:causal_graph) { nil }
      let(:expected_errors) do
        {
          errors: [
            { message: 'causal_graph: is missing', code: 'CA1001' }
          ]
        }.to_json
      end

      it { expect(subject.body).to eq(expected_errors) }
    end

    context 'when not authorized' do
      it { should have_http_status(401) }
    end

    context 'when project does not exist' do
      let(:expected_errors) do
        { errors: [{ message: "Resource not found: Project #{id}", code: 'CA1002' }] }.to_json
      end

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
      end

      it { expect(subject.body).to eq(expected_errors) }
    end

    context 'when all params are valid' do
      let(:data_schema) do
        {
          'mens' => { 'type' => 'int', 'unique_values' => 2 },
          'newbie' => { 'type' => 'int', 'unique_values' => 2 },
          'womens' => { 'type' => 'int', 'unique_values' => 2 },
          'channel' => { 'type' => 'text', 'unique_values' => 3 },
          'history' => { 'type' => 'float', 'unique_values' => 34833 },
          'outcome' => { 'type' => 'int', 'unique_values' => 6 },
          'recency' => { 'type' => 'int', 'unique_values' => 12 },
          'user_id' => { 'type' => 'int', 'unique_values' => 64000 },
          'zip_code' => { 'type' => 'text', 'unique_values' => 3 },
          'promotion' => { 'type' => 'text', 'unique_values' => 3 },
          'history_segment' => { 'type' => 'text', 'unique_values' => 7 }
        }
      end
      let(:project) do
        create(
          :project,
          user_id: user.id,
          data_imported: true,
          data_schema:
        )
      end
      let(:id) { project.id }
      let(:params) { { id:, causal_graph: } }
      let(:causal_graph) do
        {
          'outcome' => [],
          'segment' => ['outcome'],
          'history_segment' => ['outcome'],
          'newbie' => ['outcome'],
          'recency' => ['outcome'],
          'history' => ['outcome'],
          'womens' => ['outcome'],
          'mens' => ['outcome'],
          'channel' => ['outcome'],
          'zip_code' => ['outcome'],
          'promotion' => ['outcome']
        }
      end

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
