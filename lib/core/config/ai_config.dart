class AiConfig {
  final String baseUrl, model, apiKey;
  final double temperature;
  final int maxTokens;
  const AiConfig({this.baseUrl='https://api.openai.com/v1',this.model='gpt-4o-mini',this.apiKey='',this.temperature=0.7,this.maxTokens=1024});
  AiConfig copyWith({String? baseUrl,String? model,String? apiKey,double? temperature,int? maxTokens})=>AiConfig(baseUrl:baseUrl??this.baseUrl,model:model??this.model,apiKey:apiKey??this.apiKey,temperature:temperature??this.temperature,maxTokens:maxTokens??this.maxTokens);
}
