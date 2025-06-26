variable "create_compute_instance" {
  description = "Flag to create a compute instance in the Azure Machine Learning workspace."
  type        = bool
  default     = true
}

variable "ci_name" {
  description = "Name of the compute instance."
  type        = string
  default     = "boj-test-001"
}

resource "azurerm_user_assigned_identity" "msi" {
  location            = local.location
  resource_group_name = module.avm-res-resources-resourcegroup.name
  name                = "ci-boj-test-msi"
  tags                = local.tags
}

resource "azurerm_role_assignment" "sa_fdpc" {
  scope                = module.avm-res-resources-resourcegroup.resource_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_user_assigned_identity.msi.principal_id
}

resource "azapi_resource" "computeinstance" {
  count = var.create_compute_instance ? 1 : 0

  type = "Microsoft.MachineLearningServices/workspaces/computes@2024-10-01-preview"
  body = {
    properties = {
      computeLocation  = local.location
      computeType      = "ComputeInstance"
      disableLocalAuth = true
      properties = {
        enableNodePublicIp = false
        vmSize             = "Standard_E4ds_v4"
        schedules = {
          computeStartStop = [
            {
              action      = "Stop"
              triggerType = "Recurrence"
              status      = "Enabled"
              recurrence = {
                frequency = "Day"
                interval  = 1
                timeZone  = "Singapore Standard Time"
                schedule = {
                  hours     = [18]
                  minutes   = [0]
                  weekDays  = []
                  monthDays = []
                }
                startTime = "2025-06-21T00:00:00"
              }
            }
          ]
        }
      }
    }
  }
  location               = local.location
  name                   = "ci-boj-test"
  parent_id              = module.avm-res-machinelearningservices-workspace.resource_id
  response_export_values = ["*"]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.msi.id]
  }
  depends_on = [
    module.avm-res-machinelearningservices-workspace,
    module.avm-res-resources-resourcegroup,
    azurerm_user_assigned_identity.msi,
    azurerm_role_assignment.sa_fdpc
  ]
}