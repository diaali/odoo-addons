# -*- coding: utf-8 -*-
##############################################################################
#
#    Odoo Addon, Open Source Management Solution
#    Copyright (C) 2014-now Equitania Software GmbH(<http://www.equitania.de>).
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##############################################################################


from openerp import models, fields, api, _

class res_partner(models.Model):
    _inherit = 'res.partner'
    
    eq_delivery_date_type_purchase = fields.Selection([('cw', 'Calendar week'), ('date', 'Date')], string="Delivery Date Purchase", help="If nothing is selected, the default from the settings will be used.")
    eq_delivery_date_type_sale = fields.Selection([('cw', 'Calendar week'), ('date', 'Date')], string="Delivery Date Sale", help="If nothing is selected, the default from the settings will be used.")    
    eq_complete_description = fields.Char(compute='_generate_complete_description', store=True)
    
    @api.one
    @api.depends('name', 'eq_firstname')
    def _generate_complete_description(self):
        for record in self:
            if record.is_company is False:
                result = ""
                if record.name is not False:
                    result = record.name
                    
                if record.eq_firstname is not False:
                    if len(result) > 0:
                        result += ", " + record.eq_firstname 
                    else:
                        result = record.eq_firstname

                record.eq_complete_description = result  
            else:
                record.eq_complete_description = record.name