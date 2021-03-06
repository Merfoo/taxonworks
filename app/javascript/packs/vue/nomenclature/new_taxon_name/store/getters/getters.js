const GetterNames = {
	GetAllRanks: 'getAllRanks',
	ActiveModalStatus: 'activeModalStatus',
	ActiveModalType: 'activeModalType',
	ActiveModalRelationship: 'activeModalRelationship',
	GetParent: 'getParent',
	GetRankClass: 'getRankClass',
	GetRankList: 'getRankList',
	GetRelationshipList: 'getRelationshipList',
	GetStatusList: 'getStatusList',
	GetTaxonStatusList: 'getTaxonStatusList',
	GetTaxonRelationshipList: 'getTaxonRelationshipList',
	GetTaxonRelationship: 'getTaxonRelationship',
	GetTaxonType: 'getTaxonType',
	GetTaxonAuthor: 'getTaxonAuthor',
	GetTaxonFeminine: 'getTaxonFeminine',
	GetTaxonMasculine: 'getTaxonMasculine',
	GetTaxonNeuter: 'getTaxonNeuter',
	GetTaxonName: 'getTaxonName',
	GetTaxon: 'getTaxon',
	GetRoles: 'getRoles',
	GetParentRankGroup: 'getParentRankGroup',
	GetTaxonYearPublication: 'getTaxonYearPublication',
	GetNomenclaturalCode: 'getNomenclaturalCode',
	GetSoftValidation: 'getSoftValidation',
	GetHardValidation: 'getHardValidation',
	GetOriginalCombination: 'getOriginalCombination',
	GetCitation: 'getCitation',
	GetEtymology: 'getEtymology',
	GetLastChange: 'getLastChange',
	GetSaving: 'getSaving',
	GetLastSave: 'getLastSave'
};

const GetterFunctions = {
	[GetterNames.ActiveModalStatus]: require('./activeModalStatus'),
	[GetterNames.ActiveModalType]: require('./activeModalType'),
	[GetterNames.ActiveModalRelationship]: require('./activeModalRelationship'),
	[GetterNames.GetAllRanks]: require('./getAllRanks'),
	[GetterNames.GetParent]: require('./getParent'),
	[GetterNames.GetSaving]: require('./getSaving'),
	[GetterNames.GetRankClass]: require('./getRankClass'),
	[GetterNames.GetRelationshipList]: require('./getRelationshipList'),
	[GetterNames.GetRankList]: require('./getRankList'),
	[GetterNames.GetStatusList]: require('./getStatusList'),
	[GetterNames.GetTaxonStatusList]: require('./getTaxonStatusList'),
	[GetterNames.GetTaxonRelationship]: require('./getTaxonRelationship'),
	[GetterNames.GetTaxonType]: require('./getTaxonType'),
	[GetterNames.GetTaxonRelationshipList]: require('./getTaxonRelationshipList'),
	[GetterNames.GetTaxonAuthor]: require('./getTaxonAuthor'),
	[GetterNames.GetTaxonFeminine]: require('./getTaxonFeminine'),
	[GetterNames.GetTaxonMasculine]: require('./getTaxonMasculine'),
	[GetterNames.GetTaxonNeuter]: require('./getTaxonNeuter'),
	[GetterNames.GetTaxonName]: require('./getTaxonName'),
	[GetterNames.GetTaxon]: require('./getTaxon'),
	[GetterNames.GetRoles]: require('./getRoles'),
	[GetterNames.GetParentRankGroup]: require('./getParentRankGroup'),
	[GetterNames.GetTaxonYearPublication]: require('./getTaxonYearPublication'),
	[GetterNames.GetNomenclaturalCode]: require('./getNomenclaturalCode'),
	[GetterNames.GetOriginalCombination]: require('./getOriginalCombination'),
	[GetterNames.GetSoftValidation]: require('./getSoftValidation'),
	[GetterNames.GetHardValidation]: require('./getHardValidation'),
	[GetterNames.GetCitation]: require('./getCitation'),
	[GetterNames.GetEtymology]: require('./getEtymology'),
	[GetterNames.GetLastChange]: require('./getLastChange'),
	[GetterNames.GetLastSave]: require('./getLastSave')
};

module.exports = {
	GetterNames,
	GetterFunctions
}