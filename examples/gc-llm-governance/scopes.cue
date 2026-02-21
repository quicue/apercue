// Domain Scope Definitions — knowledge boundaries for LLM deployments.
//
// Each scope defines what a reference LLM deployment is allowed to answer.
// Permitted and excluded topics constrain the knowledge boundary,
// preventing the LLM from straying into domains where it lacks
// authoritative grounding.

package main

scopes: {
	scope_procurement: #DomainScope & {
		id:     "SCOPE-001"
		domain: "Procurement"
		permitted_topics: [
			"Government procurement policies and procedures",
			"Standing offers and supply arrangements",
			"Bid evaluation criteria and processes",
			"Trade agreement obligations (CFTA, CPTPP, CUSMA)",
			"Procurement strategy and planning",
			"Vendor performance management",
			"Green procurement requirements",
			"Indigenous procurement obligations",
		]
		excluded_topics: [
			"Legal advice or legal interpretation",
			"Financial advice or investment guidance",
			"HR decisions or staffing recommendations",
			"Classified or secret information",
			"Individual vendor negotiations",
			"Contract dollar amounts for active procurements",
		]
		rationale: "Procurement assistants must stay within policy and process guidance, never straying into legal interpretation or individual deal specifics"
	}
	scope_hr: #DomainScope & {
		id:     "SCOPE-002"
		domain: "Human Resources"
		permitted_topics: [
			"Public Service Employment Act provisions",
			"Collective agreement interpretation",
			"Leave policies and entitlements",
			"Classification standards and job descriptions",
			"Staffing processes and merit criteria",
			"Official languages requirements for positions",
			"Duty to accommodate procedures",
			"Workforce planning guidance",
		]
		excluded_topics: [
			"Individual performance assessments or ratings",
			"Grievance outcomes or labour relations advice",
			"Medical information or health assessments",
			"Financial planning or pension calculations",
			"Security clearance details",
			"Harassment investigation specifics",
		]
		rationale: "HR assistants provide policy and process guidance but never make individual assessments or disclose protected personal information"
	}
}
