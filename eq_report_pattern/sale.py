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
import datetime
import time
from openerp.tools import DEFAULT_SERVER_DATETIME_FORMAT

class eq_sale_order_template(models.Model):
    _inherit = 'sale.order'
   
    document_template_id = fields.Many2one(comodel_name='eq.document.template', string='Document Template', readonly=True, states={'draft': [('readonly', False)], 'sent': [('readonly', False)]})
    
    
    @api.onchange('document_template_id')
    def onchange_document_template_id(self):
        selected_template = self.document_template_id
        if (self.partner_id and self.partner_id.lang and self.document_template_id):
            selected_template = self.document_template_id.with_context(lang=self.partner_id.lang)
        
        
        if (selected_template):
            self.eq_head_text = selected_template.eq_header
            self.note = selected_template.eq_footer
            
            
            
    @api.v7
    def _prepare_invoice(self, cr, uid, order, lines, context=None):
        """
            Override of default _prepare_invoice method. We'll set value from 2 new fields from settings (eq_head_text and eq_foo_text)
            @cr: cursor
            @uid: user id
            @order: current sale order
            @lines: lines of current sale order
            @context: context
            @return: dictionary with all values of actual sale order that will be saved during standard create of an invoice
        """
        
        result = super(eq_sale_order_template, self)._prepare_invoice(cr, uid, order, lines, context=context)  
        if order:
            result['eq_head_text'] = order.eq_head_text
            result['comment'] = order.note
        
            if order.document_template_id:
                result['document_template_id'] = order.document_template_id.id
          
        return result
    